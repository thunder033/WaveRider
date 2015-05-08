import ddf.minim.analysis.*;
import ddf.minim.*;

int w;
int waves;
float theta;
float period = 1250;
float amplitude = 50;
float[] yValues;
float[] yValues2;
int xSpacing = 3;
float dx;
int pixelSize = 2;

Minim minim;
AudioPlayer mysound;
FFT fft;
FFT fftPre;

void setup()
{
  size(1250, 200);
  smooth();
  frameRate(60);
  
  w = width + pixelSize;
  
  dx = (TWO_PI / period) * xSpacing;
  yValues = new float[w/xSpacing];
  yValues2 = new float[w/xSpacing];
  
  minim = new Minim(this);
  
  //mysound = minim.loadFile("Beam (Orchestral Remix).mp3",2048);
  //mysound = minim.loadFile("05 Darkness Within.mp3",2048);
  mysound = minim.loadFile("Deorro - 5 Hours.mp3",2048);
  
  
  println(mysound.getVolume());
  
  fft = new FFT(mysound.bufferSize(), mysound.sampleRate());
  fftPre = new FFT(mysound.bufferSize(), mysound.sampleRate());
  println(fft.specSize());
  
  println(mysound.bufferSize());
  println(mysound.sampleRate());
  
  int msSkip = 100;
  int totalMs = 1;
  while(totalMs < mysound.length() && false)
  {
    //try {
      mysound.skip(msSkip);
      fftPre.forward(mysound.mix); 
      //println(fftPre.calcAvg(0, 18000));
      float avgBandAmp = 0;
      for(int i = 0; i < mysound.bufferSize(); i++)
      {
        avgBandAmp += fftPre.getBand(i);
      }
      println(avgBandAmp);
      totalMs += msSkip;
    //}
    //catch (Exception e)
    //{
    //  println(e.getMessage())
    //}
  }
  
  mysound.loop();
}

int saveFrame = 0;
void draw()
{
  background(0, 0, 0, 0);
  fft.forward(mysound.mix);
  
  fill(255,0,0);

   calcWave();
   renderWave();
   
   save("renders/output" + saveFrame + ".png");
   saveFrame++;
}



void calcWave()
{
  theta += maxAvgWave/35;
  
  float x = theta;
  /*
  for(int i = 0; i < yValues.length; i++)
  {
    yValues[i] = sin(x) * amplitude * noise((theta * 10) + x/5);
    yValues2[i] = sin(x) * amplitude * noise((theta * 10) - x/5);
    x += dx; 
  }*/
  
  for(int i = 0; i < 417; i++)
  {
    float band1 = fft.getBand(i);
    
    //float avgBand = ((band1 + band2 + band3)/3);
    
    // draw the line for frequency band i
    //ellipse(i, 300, i, 100 - avgBand);
    
    yValues[i] = band1 / 2;
  }
  
  //waveOffset = (int)(sin(theta) * (yValues.length/segments)/2);
  //pixelOffset = sin(theta) * width;
  //intln(waveOffset);
}

int segments = 8;
float[] avgSegmentAmp = new float[segments];
float[] prevSegmentAmpAvg = new float[segments];
int segmentInterval = 0;
float maxAvgWave = 0;
color segmentColors[] = {#8400FF, #001AFF, #00ECFF, #00FF4B, #BAFF00, #FFEA00, #FF7300, #FF0000};
int waveOffset = 0;
float pixelOffset = 0;
void renderWave()
{
  
  fill(0);
  segmentInterval = yValues.length/segments;
  float thetaX = theta;
  float thetaInc = .5;
  
  for(int x = 0; x < segmentInterval - 1; x++)
  {
    thetaX += thetaInc;
    for(int s = 0; s < segments; s++)
    {
      int invert = (s % 2 > 0) ? -1 : 1;
      stroke(85,225,255);
      strokeWeight(1);
      //line(x * xSpacing * 3, height/2+yValues[x], (x + 1) * xSpacing * 3, height/2+yValues[x + 1]);
      //line(x * xSpacing * 3, height/2-yValues[x], (x + 1) * xSpacing * 3, height/2-yValues[x + 1]);
      int segmentOffset = s * segmentInterval;
      
      if(segmentOffset + waveOffset + x + 1 >= yValues.length || segmentOffset + waveOffset + x < 0)
      {
          
      }
      else {
      
      float ampAdjust = 1;
      if(prevSegmentAmpAvg[s] < maxAvgWave)
      {
        ampAdjust = (maxAvgWave * 1.5f) / (prevSegmentAmpAvg[s]);  
      }
      else {
        ampAdjust = (prevSegmentAmpAvg[s]) / (maxAvgWave * 3);
      }
      
      float sinAmplitude = height/12;
      
      float x1 = (x) * xSpacing * segments + (pixelOffset % (xSpacing * segments));
      float y1 = yValues[segmentOffset + waveOffset + x];
      y1 = height/2+((y1 + prevSegmentAmpAvg[s] * invert * (y1))/2) * ampAdjust + sin(thetaX) * sinAmplitude;
      
      float x4 = (x + 1) * xSpacing * segments  + (pixelOffset % (xSpacing * segments));
      //float y4 = height/2+((yValues[segmentOffset + x + 1]/2 * invert + prevSegmentAmpAvg[s] * invert)/2) * ampAdjust;
      float y4 = yValues[segmentOffset + waveOffset + x + 1]/2;
      y4 = height/2+((y4 + prevSegmentAmpAvg[s] * invert * (y4))) * ampAdjust  + sin(thetaX + thetaInc) * sinAmplitude;
      
      avgSegmentAmp[s] += y4 - sin(thetaX + .5) * sinAmplitude;
      
      float ctrlAdjust = -xSpacing * segments/2;
      
      float x2 = x1 - ctrlAdjust;
      float y2 = y1;
      
      float x3 = x4 + ctrlAdjust;
      float y3 = y4;
      
      bezier(x1, y1, x2, y2, x3, y3, x4, y4);
      
      if(s == 0)
      {
        //stroke(255, 0, 0);
        strokeWeight(maxAvgWave / 4);
        y1 = height/2 + sin(thetaX) * sinAmplitude;
        y4 = height/2 + sin(thetaX + thetaInc) * sinAmplitude;
        y3 = y4;
        y2 = y1;
        bezier(x1, y1, x2, y2, x3, y3, x4, y4);
      }
      }
      /*
      stroke(0, 255, 255);
      int segment2 = yValues.length/3;
      line(x * xSpacing * 3, height/2+yValues[segment2 + x] * 2, (x + 1) * xSpacing * 3, height/2+yValues[segment2 + x + 1] * 2);
      line(x * xSpacing * 3, height/2-yValues[segment2 + x] * 2, (x + 1) * xSpacing * 3, height/2-yValues[segment2 + x + 1] * 2);
      
      stroke(255, 0, 255);
      int segment3 = (yValues.length/3) * 2;
      line(x * xSpacing  * 3, height/2+yValues[segment3 + x] * 3, (x + 1) * xSpacing * 3, height/2+yValues[segment3 + x + 1] * 3);
      line(x * xSpacing  * 3, height/2-yValues[segment3 + x] * 3, (x + 1) * xSpacing * 3, height/2-yValues[segment3 + x + 1] * 3);
      */
      //ellipse(x * xSpacing, height/2+yValues[x], pixelSize, pixelSize);
      //ellipse(x * xSpacing, height/2-yValues2[x], pixelSize, pixelSize);
    }
  }
  
  maxAvgWave = 0;
  for(int s = 0; s < segments; s++)
  {
     float sum = 0;
     for(int e = 0; e < segmentInterval; e++)
     {
       sum += yValues[s * segmentInterval + e];
     }
     float avg = sum / segmentInterval;
     
     if(avg > maxAvgWave)
     {
        maxAvgWave = avg;
     }
     prevSegmentAmpAvg[s] = avg;
  }
  //println(maxAvgWave);
}

void mouseClicked( )
{
  save("renders/bandOutput.png"); 
}
