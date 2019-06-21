/** This sketch allows the user to enter a logcat file, read and display timeline generated from pairs of log messages */

final int PADDING = 15;
final int LINESEP = 20;

final PVector[] colors = new PVector[] {new PVector(255, 0, 0), new PVector(0, 255, 0), new PVector(0, 0, 255)};

File selectedFile;
TimeMoment minTime = getTimeMomentMaxValue(), maxTime = getTimeMomentMinValue();
FunctionCall[] functionCalls;
String filter;

void setup() {
  size(1500, 820);
  production();
  
}

void production() {
  // Get the identifier:
  filter = javax.swing.JOptionPane.showInputDialog(frame, "What is the identifier of pair lines?", "LACTOSIS");
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
  for (FunctionCall fc : functionCalls) {
    println(fc);
    if (minTime.compare(fc.start) > 0) 
      minTime = fc.start.getCopy();
    if (maxTime.compare(fc.end) < 0) 
      maxTime = fc.end.getCopy();
  }

  println("Min time: " + minTime);
  println("Max time: " + maxTime);
}

void draw() {
  background(255);
  if (functionCalls == null) return;
  long minTimeLong = minTime.toMs();
  long maxTimeLong = maxTime.toMs();
  strokeWeight(3);
  textSize(12);

  for (int i = 0; i < functionCalls.length; i++) {
    FunctionCall fc = functionCalls[i];
    int startX = (int) map(fc.start.toMs(), minTimeLong, maxTimeLong, PADDING, width - PADDING);
    int startY = i * LINESEP + PADDING;
    int endX = (int) map(fc.end.toMs(), minTimeLong, maxTimeLong, PADDING, width - PADDING);
    int endY = startY;

    setColor(startY); 
    line(startX, startY, endX, endY);
    if (mouseY / LINESEP == startY / LINESEP)
      text(fc.functionName, 12, 12);
  }
}

void setColor(int y) {

  int colorCounter = (y / LINESEP) % colors.length;
  PVector c = colors[colorCounter];
  stroke(c.x, c.y, c.z);
  fill(c.x, c.y, c.z);
}
