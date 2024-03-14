/**
 * @description       : Used as a controller class for the FormatTime Visualforce component
 * @author            : Jamie Porche (CloudMasonry)
 * @last modified on  : 02-09-2023
 * @last modified by  : Jamie Porche (CloudMasonry)
**/
public class FormatTime {
  public Time t {get;set;}

  public FormatTime(Time t) {
      this.t = t;
  }  

  public FormatTime() {}
    
  /**
  * @description Takes a Time object and formats it into HH:mm a format.
  *              Used in the FormatTime Visualforce component.
  * @author Jamie Porche (CloudMasonry) | 02-08-2023 
  * @return string Time formatted as HH:mm a. If the time object is null, it returns 
  *                 an empty string.
  **/
  public String getFormattedTime() {
    if (t == null) return '';

    Integer hour = t.hour();
    Integer minute = t.minute();
    String ampm = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12; 

    return hour.format() + ':' + minute.format().leftPad(2, '0') + ' ' + ampm;
  }
}