module days;

class daysCacheClass {
    public:
    ushort[12] monthOffsets;
    ushort[12] monthOffsetsLeap;
    char[7] convert;
    this() {
        monthOffsets = [
            0, 31, 59, 90,
            120, 151, 181, 212,
            243, 273, 304, 334
        ];
        monthOffsetsLeap = [
            0, 31, 60, 91,
            121, 152, 182, 213,
            244, 274, 305, 335
        ];
        convert = [
            'A', 'U', 'M', 'T', 'W', 'R', 'F'
        ];
    }
}

immutable daysCacheClass daysCache;

shared static this() {
    daysCache = cast(immutable daysCacheClass) new daysCacheClass;
}

alias daysIndex = int;

struct daysDate {
    ushort year;
    ubyte month;
    ubyte day;
}

daysIndex encode(uint year, uint month, uint day) {
    if (month > 12 || month < 1) {
        throw new Exception("Bad Month");
    }
    if (day > 31 || day < 1) {
        throw new Exception("Bad Day");
    }
    uint yearMod = year % 400;
    daysIndex output;
    output = (day - 1);
    if (yearMod % 4 == 0) {
        output += daysCache.monthOffsetsLeap[month-1];
    }
    else {
        output += daysCache.monthOffsets[month-1];
    }
    output += yearMod * 365;
    output += (yearMod + 3) / 4; // number of leap days
    // now correct for missing leap days
    if (output >= 73110) {
        // 1 mar 200
        if (output >= 109635) {
            // 1 mar 300
            output -= 3;
        }
        else {
            output -= 2;
        }
    }
    else {
        if (output >= 36585) {
            // 1 mar 100
            output -= 1;
        }
    }
    output += (year / 400) * 146097;
    return output;
}

daysIndex encode(daysDate date) {
    return encode(date.year,date.month,date.day);
}

char dayOfWeek(daysIndex index) {
    return daysCache.convert[index % 7];
}

ubyte dayOfWeekMonday(daysIndex index) {
    return cast(ubyte) ((index + 5) % 7);
}

ubyte dayOfWeekSunday(daysIndex index) {
    return cast(ubyte) ((index + 6) % 7);
}

ubyte getMonth(ref daysIndex index, immutable ushort * array) {
    uint guess = (index / 28);
    if (guess > 11) {
        guess = 11;
    }
    while (array[guess] > index) {
        guess--;
    }
    index -= array[guess];
    return cast(ubyte) (guess + 1);
}

daysDate decode(daysIndex index) {
    if (index > 23936531 || index < 0) {
        throw new Exception("Bad Index");
    }
    daysDate output;
    output.year = cast(ushort) ((index / 146097) * 400);
    index %= 146097;
    // correct for missing leap years
    if (index >= 73108) {
        // 1 mar 200
        if (index >= 109632) {
            // 1 mar 300
            index += 3;
        }
        else {
            index += 2;
        }
    }
    else {
        if (index >= 36584) {
            // 1 mar 100
            index += 1;
        }
    }
    output.year += (index / 1461) * 4;
    index %= 1461;
    if (index >= 731) {
        if (index >= 1096) {
            // in fourth year
            output.year += 3;
            index -= 1096;
        }
        else {
            // in third year
            output.year += 2;
            index -= 731;
        }
    }
    else {
        if (index >= 366) {
            // in second year
            output.year += 1;
            index -= 366;
        }
    }
    // year is fully set
    if (output.year % 4 == 0) {
        output.month = getMonth(index,&daysCache.monthOffsetsLeap[0]);
    }
    else {
        output.month = getMonth(index,&daysCache.monthOffsets[0]);
    }
    // month is set
    output.day = cast(ubyte) (index + 1);
    return output;
}
