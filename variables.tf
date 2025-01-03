variable "city_data" {
  type = list(object({
    city       = string
    company    = string
    latitude   = number
    longitude  = number
  }))
  default = [
    { city = "Ashburn, VA",       company = "Capital One",           latitude = 39.0438, longitude = -77.4874 },
    { city = "Dallas, TX",         company = "Comerica Bank",         latitude = 32.7767, longitude = -96.7970 },
    { city = "San Francisco, CA",  company = "Wells Fargo",           latitude = 37.7749, longitude = -122.4194 },
    { city = "New York, NY",       company = "JPMorgan Chase",        latitude = 40.7128, longitude = -74.0060 },
    { city = "Charlotte, NC",      company = "Bank of America",       latitude = 35.2271, longitude = -80.8431 },
    { city = "Chicago, IL",        company = "Northern Trust",        latitude = 41.8781, longitude = -87.6298 },
    { city = "Boston, MA",         company = "State Street",          latitude = 42.3601, longitude = -71.0589 },
    { city = "Atlanta, GA",        company = "SunTrust Bank",         latitude = 33.7490, longitude = -84.3880 },
    { city = "Seattle, WA",        company = "Washington Mutual",     latitude = 47.6062, longitude = -122.3321 },
    { city = "Miami, FL",          company = "City National Bank",    latitude = 25.7617, longitude = -80.1918 },
    { city = "Phoenix, AZ",        company = "Western Alliance",      latitude = 33.4484, longitude = -112.0740 },
    { city = "Denver, CO",         company = "FirstBank",             latitude = 39.7392, longitude = -104.9903 },
    { city = "Orlando, FL",        company = "Seacoast National",     latitude = 28.5383, longitude = -81.3792 },
    { city = "Las Vegas, NV",      company = "Nevada State Bank",     latitude = 36.1699, longitude = -115.1398 },
    { city = "San Diego, CA",      company = "Union Bank",            latitude = 32.7157, longitude = -117.1611 },
    { city = "Portland, OR",       company = "Umpqua Bank",           latitude = 45.5051, longitude = -122.6750 },
    { city = "Houston, TX",        company = "BBVA Compass",          latitude = 29.7604, longitude = -95.3698 },
    { city = "Austin, TX",         company = "Frost Bank",            latitude = 30.2672, longitude = -97.7431 },
    { city = "Detroit, MI",        company = "Flagstar Bank",         latitude = 42.3314, longitude = -83.0458 },
    { city = "Indianapolis, IN",   company = "First Merchants",       latitude = 39.7684, longitude = -86.1581 },
    { city = "Nashville, TN",      company = "Pinnacle Bank",         latitude = 36.1627, longitude = -86.7816 },
    { city = "San Antonio, TX",    company = "Broadway Bank",         latitude = 29.4241, longitude = -98.4936 },
    { city = "Baltimore, MD",      company = "Howard Bank",           latitude = 39.2904, longitude = -76.6122 },
    { city = "Cleveland, OH",      company = "KeyBank",               latitude = 41.4993, longitude = -81.6944 },
    { city = "Philadelphia, PA",   company = "WSFS Bank",             latitude = 39.9526, longitude = -75.1652 },
    { city = "Tampa, FL",          company = "BayFirst Financial",    latitude = 27.9506, longitude = -82.4572 },
    { city = "Minneapolis, MN",    company = "TCF Bank",              latitude = 44.9778, longitude = -93.2650 },
    { city = "St. Louis, MO",      company = "UMB Bank",              latitude = 38.6270, longitude = -90.1994 },
    { city = "Pittsburgh, PA",     company = "FNB Corporation",       latitude = 40.4406, longitude = -79.9959 },
    { city = "Cincinnati, OH",     company = "Fifth Third Bank",      latitude = 39.1031, longitude = -84.5120 },
    { city = "Sacramento, CA",     company = "Golden 1 Credit Union", latitude = 38.5816, longitude = -121.4944 },
    { city = "Kansas City, MO",    company = "Commerce Bank",         latitude = 39.0997, longitude = -94.5786 },
    { city = "Columbus, OH",       company = "Huntington Bank",       latitude = 39.9612, longitude = -82.9988 },
    { city = "Milwaukee, WI",      company = "Associated Bank",       latitude = 43.0389, longitude = -87.9065 },
    { city = "Louisville, KY",     company = "Republic Bank",         latitude = 38.2527, longitude = -85.7585 },
    { city = "Richmond, VA",       company = "Atlantic Union Bank",   latitude = 37.5407, longitude = -77.4360 },
    { city = "Oklahoma City, OK",  company = "MidFirst Bank",         latitude = 35.4676, longitude = -97.5164 },
    { city = "Memphis, TN",        company = "First Horizon Bank",    latitude = 35.1495, longitude = -90.0490 },
    { city = "Raleigh, NC",        company = "First Citizens Bank",   latitude = 35.7796, longitude = -78.6382 },
    { city = "Salt Lake City, UT", company = "Zions Bank",            latitude = 40.7608, longitude = -111.8910 },
    { city = "Jacksonville, FL",   company = "VyStar Credit Union",   latitude = 30.3322, longitude = -81.6557 },
    { city = "New Orleans, LA",    company = "First Bank and Trust",  latitude = 29.9511, longitude = -90.0715 },
    { city = "Buffalo, NY",        company = "M&T Bank",              latitude = 42.8864, longitude = -78.8784 },
    { city = "Fort Worth, TX",     company = "Northstar Bank",        latitude = 32.7555, longitude = -97.3308 },
    { city = "Omaha, NE",          company = "First National Bank",   latitude = 41.2565, longitude = -95.9345 },
    { city = "Honolulu, HI",       company = "Bank of Hawaii",        latitude = 21.3069, longitude = -157.8583 },
    { city = "Des Moines, IA",     company = "Bankers Trust",         latitude = 41.5868, longitude = -93.6250 },
    { city = "Anchorage, AK",      company = "Northrim Bank",         latitude = 61.2181, longitude = -149.9003 },
    { city = "Boise, ID",          company = "Idaho Central Credit",  latitude = 43.6150, longitude = -116.2023 },
    { city = "Los Angeles, CA",    company = "City National Bank",       latitude = 34.0522, longitude = -118.2437 },
    { city = "Phoenix, AZ",        company = "Western Alliance Bank",    latitude = 33.4484, longitude = -112.0740 },
    { city = "Denver, CO",         company = "FirstBank",                latitude = 39.7392, longitude = -104.9903 },
    { city = "Houston, TX",        company = "BBVA Compass",             latitude = 29.7604, longitude = -95.3698 },
    { city = "Las Vegas, NV",      company = "Nevada State Bank",        latitude = 36.1699, longitude = -115.1398 },
    { city = "Portland, OR",       company = "Umpqua Bank",              latitude = 45.5152, longitude = -122.6784 },
    { city = "Minneapolis, MN",    company = "US Bank",                  latitude = 44.9778, longitude = -93.2650 },
    { city = "Cleveland, OH",      company = "KeyBank",                  latitude = 41.4993, longitude = -81.6944 },
    { city = "Indianapolis, IN",   company = "Old National Bank",        latitude = 39.7684, longitude = -86.1581 },
    { city = "Detroit, MI",        company = "Comerica Bank",            latitude = 42.3314, longitude = -83.0458 },
    { city = "Columbus, OH",       company = "Huntington Bank",          latitude = 39.9612, longitude = -82.9988 },
    { city = "Milwaukee, WI",      company = "Associated Bank",          latitude = 43.0389, longitude = -87.9065 },
    { city = "Nashville, TN",      company = "Pinnacle Financial",       latitude = 36.1627, longitude = -86.7816 },
    { city = "Kansas City, MO",    company = "Commerce Bank",            latitude = 39.0997, longitude = -94.5786 },
    { city = "St. Louis, MO",      company = "Stifel Financial",         latitude = 38.6270, longitude = -90.1994 },
    { city = "Cincinnati, OH",     company = "Fifth Third Bank",         latitude = 39.1031, longitude = -84.5120 },
    { city = "Orlando, FL",        company = "Seacoast Bank",            latitude = 28.5383, longitude = -81.3792 },
    { city = "Tampa, FL",          company = "Raymond James",            latitude = 27.9506, longitude = -82.4572 },
    { city = "Pittsburgh, PA",     company = "PNC Bank",                 latitude = 40.4406, longitude = -79.9959 },
    { city = "Newark, NJ",         company = "Prudential Financial",     latitude = 40.7357, longitude = -74.1724 },
    { city = "Buffalo, NY",        company = "M&T Bank",                 latitude = 42.8864, longitude = -78.8784 },
    { city = "New Orleans, LA",    company = "Hancock Whitney",          latitude = 29.9511, longitude = -90.0715 },
    { city = "Salt Lake City, UT", company = "Zions Bank",               latitude = 40.7608, longitude = -111.8910 },
    { city = "Omaha, NE",          company = "First National Bank",      latitude = 41.2565, longitude = -95.9345 },
    { city = "Albuquerque, NM",    company = "New Mexico Bank & Trust",  latitude = 35.0844, longitude = -106.6504 },
    { city = "Birmingham, AL",     company = "Regions Bank",             latitude = 33.5186, longitude = -86.8104 },
    { city = "Louisville, KY",     company = "Republic Bank",            latitude = 38.2527, longitude = -85.7585 },
    { city = "Richmond, VA",       company = "Atlantic Union Bank",      latitude = 37.5407, longitude = -77.4360 },
    { city = "Hartford, CT",       company = "Webster Bank",             latitude = 41.7658, longitude = -72.6734 },
    { city = "Raleigh, NC",        company = "First Citizens Bank",      latitude = 35.7796, longitude = -78.6382 },
    { city = "Providence, RI",     company = "Citizens Bank",            latitude = 41.8240, longitude = -71.4128 },
    { city = "Virginia Beach, VA", company = "TowneBank",                latitude = 36.8529, longitude = -75.9780 },
    { city = "Jacksonville, FL",   company = "VyStar Credit Union",      latitude = 30.3322, longitude = -81.6557 },
    { city = "Memphis, TN",        company = "First Horizon Bank",       latitude = 35.1495, longitude = -90.0490 },
    { city = "Oklahoma City, OK",  company = "BOK Financial",            latitude = 35.4676, longitude = -97.5164 },
    { city = "Des Moines, IA",     company = "Bankers Trust",            latitude = 41.5868, longitude = -93.6250 },
    { city = "Little Rock, AR",    company = "Simmons Bank",             latitude = 34.7465, longitude = -92.2896 },
    { city = "Anchorage, AK",      company = "Northrim Bank",            latitude = 61.2181, longitude = -149.9003 },
    { city = "Boise, ID",          company = "Idaho Central Credit Union",latitude = 43.6150, longitude = -116.2023 },
    { city = "Spokane, WA",        company = "Washington Trust Bank",    latitude = 47.6588, longitude = -117.4260 },
    { city = "Fargo, ND",          company = "Gate City Bank",           latitude = 46.8772, longitude = -96.7898 },
    { city = "Billings, MT",       company = "First Interstate Bank",    latitude = 45.7833, longitude = -108.5007 },
    { city = "Sioux Falls, SD",    company = "Great Western Bank",       latitude = 43.5446, longitude = -96.7311 },
    { city = "Honolulu, HI",       company = "First Hawaiian Bank",      latitude = 21.3069, longitude = -157.8583 },
    { city = "Madison, WI",        company = "Park Bank",                latitude = 43.0731, longitude = -89.4012 },
    { city = "Knoxville, TN",      company = "Home Federal Bank",        latitude = 35.9606, longitude = -83.9207 },
    { city = "Augusta, GA",        company = "Georgia Bank & Trust",     latitude = 33.4735, longitude = -82.0105 },
    { city = "Wichita, KS",        company = "INTRUST Bank",             latitude = 37.6872, longitude = -97.3301 },
    { city = "El Paso, TX",        company = "WestStar Bank",            latitude = 31.7619, longitude = -106.4850 }
  ]
}
