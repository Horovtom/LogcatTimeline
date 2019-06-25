class FunctionCall {
  String functionName;
  TimeMoment start;
  TimeMoment end;

  boolean hasBothTimes() {
    return start != null && end != null;
  }

  FunctionCall(String functionName) {
    this.functionName = functionName;
  }

  public String toString() {
    return functionName + " from: " + start + " to: " + end;
  }
}

/**
 * @return A list of arrays of function calls. Each array in the list represents one function. Elements of the array are the individual calls in time of the same function
 */
public ArrayList<FunctionCall[]> getFunctionCalls(File file, String filter) {
  int createdFunctionCalls = 0;
  HashMap<String, ArrayList<FunctionCall>> functionCalls = new HashMap<String, ArrayList<FunctionCall>>();
  String[] lines = loadStrings(file);
  for (String line : lines) {
    if (!line.contains(filter)) continue;

    // Example line from logcat:
    // 06-21 14:51:15.842 11351 11351 D TrafficLog: LACTOSIS: refreshAvatars::start
    String[] tokens = line.split(" ");
    if (tokens.length < 6) {
      println("Error reading line: " + line);
      continue;
    }
    TimeMoment moment = new TimeMoment(tokens[1]);
    String[] function = tokens[tokens.length - 1].split("::");
    String functionName = function[0];
    boolean isEnd = function[1].equals("end");

    if (functionCalls.containsKey(functionName)) {
      ArrayList<FunctionCall> lastCalls = functionCalls.get(functionName);

      FunctionCall lastOne = null;
      // Handle recursion
      int i = lastCalls.size() - 1;
      while (i >= 0) {
        lastOne = lastCalls.get(i);
        if (!lastOne.hasBothTimes()) break;
        i--;
      }

      if (lastOne == null) {
        println("Error in log! We have possible recursion of function: " + functionName + " but without the starting call");
        continue;
      }

      if (isEnd) {
        lastOne.end = moment;
      } else {
        lastOne = new FunctionCall(functionName);
        lastOne.start = moment; 
        lastCalls.add(lastOne);
        createdFunctionCalls++;
      }
    } else {

      ArrayList<FunctionCall> newList = new ArrayList<FunctionCall>();
      FunctionCall funcCall = new FunctionCall(functionName);
      funcCall.start = moment;
      newList.add(funcCall);
      functionCalls.put(functionName, newList);
      createdFunctionCalls++;
    }
  }

  //FunctionCall[] returning = new FunctionCall[createdFunctionCalls];
  //int index = 0;
  //for (ArrayList<FunctionCall> functionCallList : functionCalls.values()) {
  //  for (FunctionCall fc : functionCallList) {
  //    returning[index++] = fc;
  //  }
  //}
  
  ArrayList<FunctionCall[]> returning = new ArrayList<FunctionCall[]>();
  for (ArrayList<FunctionCall> functionCallList: functionCalls.values()) {
   FunctionCall[] arr = new FunctionCall[functionCallList.size()];
   int i = 0;
   for (FunctionCall fc: functionCallList) {
    arr[i++] = fc; 
   }
   returning.add(arr);
  }

  return returning;
}
