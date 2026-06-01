#!/usr/bin/env python3
import argparse
from datetime import datetime, timedelta
import pytz

def get_business_dates(tz_name: str = 'Asia/Bangkok', boundary_hour: int = 7):
    tz = pytz.timezone(tz_name)
    now = datetime.now(tz)
    
    # Shift time back by boundary_hour
    # So if it's 06:59, shifted is 23:59 of the previous day
    # If it's 07:00, shifted is 00:00 of today
    shifted = now - timedelta(hours=boundary_hour)
    current_biz_day = shifted.date()
    previous_biz_day = current_biz_day - timedelta(days=1)
    
    return {
        "current_business_day": current_biz_day.strftime("%Y-%m-%d"),
        "previous_business_day": previous_biz_day.strftime("%Y-%m-%d"),
        "real_time": now.strftime("%Y-%m-%d %H:%M:%S %Z")
    }

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Get business day based on a boundary hour.")
    parser.add_argument("--tz", default="Asia/Bangkok")
    parser.add_argument("--boundary", type=int, default=7, help="Hour boundary (0-23)")
    parser.add_argument("--target", choices=["current", "previous"], default="current")
    args = parser.parse_args()
    
    dates = get_business_dates(args.tz, args.boundary)
    if args.target == "current":
        print(dates["current_business_day"])
    else:
        print(dates["previous_business_day"])
