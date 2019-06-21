class TimeMoment {
  int hours;
  int minutes;
  int seconds;
  int milliseconds;


  TimeMoment(int hours, int minutes, int seconds, int milliseconds) {
    this.hours = hours;
    this.minutes = minutes;
    this.seconds = seconds;
    this.milliseconds = milliseconds;
  }

  TimeMoment(String timeString) {
    // TimeString looks like: 
    //14:51:15.842
    String[] pieces = timeString.split(":");
    hours = Integer.parseInt(pieces[0]);
    minutes = Integer.parseInt(pieces[1]);
    float s = float(pieces[2]);
    seconds = (int) s;
    milliseconds = ((int) (s * 1000)) % 1000;
  }

  public long toMs() {
    return (((hours * 60 + minutes) * 60 + seconds) * 1000L + milliseconds);
  }

  TimeMoment(long ms) {
    milliseconds = (int) (ms % 1000);
    seconds = (int) (ms / 1000);
    int secondsInHour = 60*60;
    hours = seconds / secondsInHour;
    seconds %= secondsInHour;
    minutes = seconds / 60;
    seconds %= 60;
  }

  public String toString() {
    return hours + ":" + minutes + ":" + seconds + "." + milliseconds;
  }

  public int compare(Object other) {
    if (other instanceof TimeMoment) {
      TimeMoment ot = (TimeMoment) other;
      return Long.compare(toMs(), ot.toMs());
    } else if (other instanceof Long) {
      return Long.compare(toMs(), (Long) other);
    }
    return 0;
  }

  public TimeMoment getCopy() {
    return new TimeMoment(toMs());
  }
}

public TimeMoment getTimeMomentMaxValue() {
  return new TimeMoment(23, 59, 59, 999);
}

public TimeMoment getTimeMomentMinValue() {
  return   new TimeMoment(0, 0, 0, 0);
}
