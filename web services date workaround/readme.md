2023-12-26 sw
Web services calls to create a ticket task using a date value from a ticket form is sent from the ticketing app to the webservice engine as a date, but the value is cast into a datetime and returned from the webservice engine to the ticketing app with the local time zone offset applied:
 
 date from ticket 2023-12-15
  webservce engine converts that to a datetime 2023-12-15T00:00:00Z (server time is UTC)
  date in bound to ticketing app is 2023-12-14T17:00:00

The resulting ticket task is created six hours (or whatever the time zone offset is) before the date that was sent to the webservice engine.

A workaround is to send the date to a function ahead of the call to create the ticket task to add an offset +6hrs (or the local time zone offset).

The function was set up in AWS as a Lambda function and tested successfully:

import json
import datetime

def lambda_handler(event, context):
    # print(event)
    strReturnDate = event['queryStringParameters']['tdxDate']

    strYear = strReturnDate[0:4]
    strMonth = strReturnDate[5:7]
    strDay = strReturnDate[8:11]

    # Hours = time zone offset plus 8 for 8am (CST)
    dtStart = datetime.datetime(int(strYear), int(strMonth), int(strDay), 13, 0, 0, 0 )
    format_data = "%Y-%m-%dT%H:%M:%SZ"
    returnDate = dtStart.strftime(format_data)
    #print(dtStart)
    #print(returnDate)
    
    #jsonDate = json.dumps(returnDate, ensure_ascii = False)
    #print(type(returnDate), " ", jsonDate)
    
    dictReturn = {'yourDate': returnDate}
    jsonReturn = json.dumps(dictReturn)
    return jsonReturn
