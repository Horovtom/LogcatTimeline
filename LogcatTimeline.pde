/** This sketch allows the user to enter a logcat file, read and display timeline generated from pairs of log messages */

final int PADDING = 15;
final int LINESEP = 20;

final PVector[] colors = new PVector[] {new PVector(255, 0, 0), new PVector(0, 255, 0), new PVector(0, 0, 255)};

File selectedFile;
TimeMoment minTime = getTimeMomentMaxValue(), maxTime = getTimeMomentMinValue();
ArrayList<FunctionCall[]> functionCalls;
String filter;
int zoom = 1;
TimeMoment lowerTime, upperTime;

void setup() {
  size(1500, 820);
  production();
}

void production() {
  // Get the identifier:
  filter = javax.swing.JOptionPane.showInputDialog(frame, "What is the identifier of pair lines?", "LACTOSIS");
  if (filter == null) exit();
  println("Prefix identifier: " + filter);


  // Select a file:
  selectInput("Select a file to process:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    exit();
    return;
  }
  selectedFile = selection;
  println("Selected file: " + selection.getAbsolutePath());
  functionCalls = getFunctionCalls(selectedFile, filter);
  for (FunctionCall[] l : functionCalls) {
    for (FunctionCall fc : l) {
      if (minTime.compare(fc.start) > 0) 
        minTime = fc.start.getCopy();
      if (maxTime.compare(fc.end) < 0) 
        maxTime = fc.end.getCopy();
    }
  }

  println("Min time: " + minTime);
  println("Max time: " + maxTime);
  lowerTime = minTime.getCopy();
  upperTime = maxTime.getCopy();
}

void draw() {
  background(255);

  if (functionCalls == null) return;
  long lowerTimeLong = lowerTime.toMs();
  long upperTimeLong = upperTime.toMs();

  strokeWeight(3);
  textSize(12);
  text("+, <-, ->, SPACE", width - 150, 12);

  for (int j = 0; j < functionCalls.size(); j++) {
    int y = j * LINESEP + PADDING;
    FunctionCall[] curr = functionCalls.get(j);
    double sum = 0;
    for (int i = 0; i < curr.length; i++) {
      FunctionCall fc = curr[i];
      sum += duration(fc.start, fc.end);
      // If we are on last functionCall of the row, we can display the text even with the average...
      if (i == curr.length - 1 && mouseY / LINESEP == y / LINESEP)
        text(fc.functionName + " - AVG: " + (sum / curr.length) + "ms * " + curr.length + " = " + (sum / 1000) + "s.", 12, 12);

      if (fc.end.compare(lowerTime) < 0 || fc.start.compare(upperTime) > 0) 
        // It is out of our zoom bounds
        continue;

      int startX = PADDING, endX = width - PADDING;
      startX = max(startX, 
        (int) map(fc.start.toMs(), lowerTimeLong, upperTimeLong, PADDING, width - PADDING));
      endX = min(endX, 
        (int) map(fc.end.toMs(), lowerTimeLong, upperTimeLong, PADDING, width - PADDING));

      setColor(i);
      line(startX, y, endX, y);
    }
  }
}

void keyPressed() {
  TimeMoment middle = new TimeMoment((lowerTime.toMs() + upperTime.toMs()) / 2);
  if (key == '+') {
    // zoom in
    lowerTime = new TimeMoment((middle.toMs() + lowerTime.toMs()) / 2);
    upperTime = new TimeMoment((upperTime.toMs() + middle.toMs()) / 2);
  } else if (key == '-') {
    // zoom out
    lowerTime = new TimeMoment(middle.toMs() - 2*duration(lowerTime, middle));
    upperTime = new TimeMoment(middle.toMs() + 2*duration(middle, upperTime));
  } else if (keyCode == LEFT) {
    // move left
    TimeMoment oldLowerTime = lowerTime.getCopy();
    lowerTime = new TimeMoment(
      (int) max(minTime.toMs(), 
      lowerTime.toMs() - duration(lowerTime, middle)));
    long dist = duration(lowerTime, oldLowerTime);
    upperTime = new TimeMoment(upperTime.toMs() - dist);
  } else if (keyCode == RIGHT) {
    // move right
    TimeMoment oldUpperTime = upperTime.getCopy();
    upperTime = new TimeMoment(
      (int) min(maxTime.toMs(), 
      upperTime.toMs() + duration(middle, upperTime)));
    long dist = duration(oldUpperTime, upperTime);
    lowerTime = new TimeMoment(lowerTime.toMs() + dist);
  } else if (key == ' ') {
    // Reset 
    lowerTime = minTime.getCopy();
    upperTime = maxTime.getCopy();
  }
  
  println("New lowerTime: " + lowerTime);
  println("New upperTime: " + upperTime);
}

void setColor(int i) {

  int colorCounter = i % colors.length;
  PVector c = colors[colorCounter];
  stroke(c.x, c.y, c.z);
  fill(c.x, c.y, c.z);
}
