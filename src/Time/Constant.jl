
# / Add this offset to convert Modified Julian Date to Julian Date.
const MJD_TO_JD = 2400000.5
# / Modified Julian Date of UNIX epoch (Jan. 1, 1970).
const UNIX_DT = DateTime(1970, 1, 1, 0, 0, 0)
const UNIX_JD = datetime2julian(UNIX_DT)

# / Seconds per half week.
const HALFWEEK = 302400
# / Seconds per whole week.
const FULLWEEK = 604800
# / Seconds per day.
const SEC_PER_DAY = 86400
# / Days per second.
const DAY_PER_SEC = 1.0 / SEC_PER_DAY


# / Milliseconds in a second.
const MS_PER_SEC = 1000
# / Seconds per millisecond.
const SEC_PER_MS = 1.0 / MS_PER_SEC

# / Milliseconds in a day.
const MS_PER_DAY = MS_PER_SEC * SEC_PER_DAY
# / Days per milliseconds.
const DAY_PER_MS = 1.0 / MS_PER_DAY

# system-specific constants

# GPS -------------------------------------------
# / 'Julian day' of GPS epoch (Jan. 6, 1980).
const GPS_EPOCH_DT = DateTime(1980, 1, 6, 0, 0, 0)
const GPS_EPOCH_JD = datetime2julian(GPS_EPOCH_DT)

# / Weeks per GPS Epoch
const GPS_WEEK_PER_EPOCH = 1024

# / Zcounts in a  day.
const ZCOUNT_PER_DAY = 57600
# / Days in a Zcount
const DAY_PER_ZCOUNT = 1.0 / ZCOUNT_PER_DAY
# / Zcounts in a week.
const ZCOUNT_PER_WEEK = 403200
# / Weeks in a Zcount.
const WEEK_PER_ZCOUNT = 1.0 / ZCOUNT_PER_WEEK
# / Z-counts per minute.
const ZCOUNT_PER_MINUTE = 40
# / Z-counts per hour.
const ZCOUNT_PER_HOUR = 2400


# GAL -------------------------------------------
# / 'Julian day' of GAL epoch (Aug 22 1999)
const GAL_EPOCH_DT = DateTime(1999, 8, 22, 0, 0, 0)
const GAL_EPOCH_JD = datetime2julian(GAL_EPOCH_DT)

const GAL_WEEK_PER_EPOCH = 4096


# QZS -------------------------------------------
# / 'Julian day' of QZS epoch (Jan. 1, 1980).
const QZS_EPOCH_DT = GPS_EPOCH_DT
const QZS_EPOCH_JD = GPS_EPOCH_JD
const QZS_WEEK_PER_EPOCH = 65535

# BDS -------------------------------------------
# / 'Julian day' of BDS epoch (Jan. 1, 2006).
const BDS_EPOCH_DT = DateTime(2006, 1, 1, 0, 0, 0)
const BDS_EPOCH_JD = datetime2julian(BDS_EPOCH_DT) # 2453736.5

const BDS_WEEK_PER_EPOCH = 8192

# IRN -------------------------------------------
# / 'Julian day' of IRN epoch (Aug 22, 1999).
const IRN_EPOCH_DT = DateTime(1999, 8, 22, 0, 0, 0)
const IRN_EPOCH_JD = datetime2julian(IRN_EPOCH_DT) # 2451412.5

const IRN_WEEK_PER_EPOCH = 1024

