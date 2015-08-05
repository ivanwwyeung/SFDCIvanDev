public class DateTimeUtil {

	//http://www.interactiveties.com/b_apex_time_duration.php
    
    public static String segment_text(String segment_string, Integer segment_integer, String prior_segments) {
        String return_string; //string for returning
        String spacer = ''; //string for holding an additional spacer
        if (segment_string != 'Second') { //if the segment being determined is not Seconds
            spacer = ' '; //create a spacer value
        }
        if (segment_integer > 1) { //if the value is greater than 1
            return_string = segment_integer.format()+' '+segment_string+'s'+spacer; //format
        } else if (segment_integer > 0) { //if the value is greater than 0
            return_string = segment_integer.format()+' '+segment_string+spacer; //format
        } else { //otherwise
            if (prior_segments != '' || segment_string == 'Second') { //if there is a value for prior segments or this is the seconds segment
                return_string = '0 '+segment_string+'s'+spacer; //format
            } else {
                return_string = ''; //set variable to null
            }
        }
        return return_string; //pass back the string
    }
    
    public static String duration_between_two_date_times(DateTime start_date_time, DateTime end_date_time) {
        Integer start_year_as_int = start_date_time.year(); //grab the start year
        Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
        Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
        Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
        Integer start_second_as_int = start_date_time.second(); //grab the start second
        Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
        //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
        Integer end_year_as_int = end_date_time.year(); //grab the end year
        Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
        Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
        Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
        Integer end_second_as_int = end_date_time.second(); //grab the end second
        Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
        Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        Integer year_result = math.mod(math.floor(total_duration_in_seconds/31556926).intValue(),10000000); //number of years
        Integer day_result = math.mod(math.floor(total_duration_in_seconds/86400).intValue(),365); //number of days
        Integer hour_result = math.mod(math.floor(total_duration_in_seconds/3600).intValue(),24); //number of hours
        Integer minute_result = math.mod(math.floor(total_duration_in_seconds/60).intValue(),60); //number of minutes
        Integer second_result = math.mod(math.floor(total_duration_in_seconds/1).intValue(),60); //number of seconds
        
        String year_text_string = segment_text('Year', year_result, ''); //string variable for text regarding Year
        String day_text_string = segment_text('Day', day_result, year_text_string); //string variable for text regarding Day
        String hour_text_string = segment_text('Hour', hour_result, year_text_string + day_text_string); //string variable for text regarding Hour
        String minute_text_string = segment_text('Minute', minute_result, year_text_string + day_text_string + hour_text_string); //string variable for text regarding Minute
        String second_text_string = segment_text('Second', second_result, year_text_string + day_text_string + hour_text_string + minute_text_string); //string variable for text regarding Second
        String return_string = year_text_string + day_text_string + hour_text_string + minute_text_string + second_text_string;//concatenate all the strings into one for our resutling test string
        return return_string; //pass back the final string
    }
    
/*
    //test for the time_calculation methods
    static testMethod void test_duration() {
        //validate that multiple years works properly
        DateTime dt1 = DateTime.valueOf('2007-01-01 2:35:21'); //datetime start variable
        DateTime dt2 = DateTime.valueOf('2010-01-02 3:56:45'); //datetime end variable
        System.assertEquals('3 Years 1 Day 18 Hours 47 Minutes 42 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate that single year works properly and 0 days too
        dt1 = DateTime.newInstance(2009, 1, 1, 2, 35, 21); //datetime start variable
        dt2 = DateTime.newInstance(2010, 1, 1, 2, 56, 45); //datetime end variable
        System.assertEquals('1 Year 0 Days 6 Hours 10 Minutes 10 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate that 0 year works properly
        dt1 = DateTime.newInstance(2010, 1, 1, 2, 35, 21); //datetime start variable
        dt2 = DateTime.newInstance(2010, 1, 2, 4, 56, 45); //datetime end variable
        System.assertEquals('1 Day 2 Hours 21 Minutes 24 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate that greater than 1 day works properly plus 1 second
        dt1 = DateTime.valueOf('2010-01-01 3:12:55'); //datetime start variable
        dt2 = DateTime.valueOf('2010-01-04 11:34:56'); //datetime end variable
        System.assertEquals('3 Days 8 Hours 22 Minutes 1 Second', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate that 1 hour, 1 minute and 0 days works properly
        dt1 = DateTime.valueOf('2010-06-21 13:12:55'); //datetime start variable
        dt2 = DateTime.valueOf('2010-06-21 14:14:23'); //datetime end variable
        System.assertEquals('1 Hour 1 Minute 28 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate one second
        dt1 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime start variable
        dt2 = DateTime.valueOf('2010-09-09 20:57:01'); //datetime end variable
        System.assertEquals('1 Second', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //valaidate that 0 hour works properly
        dt1 = DateTime.newInstance(2010, 1, 1, 2, 35, 21); //datetime start variable
        dt2 = DateTime.newInstance(2010, 1, 1, 2, 56, 45); //datetime end variable
        System.assertEquals('21 Minutes 24 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
        
        //validate zero seconds
        dt1 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime start variable
        dt2 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime end variable
        System.assertEquals('0 Seconds', DateTimeUtil.duration_between_two_date_times(dt1, dt2));
    }
  */
    
}