def isLeapYear(year):
    if year % 4 != 0:
        return False
    if year % 100 != 0:
        return True
    if year % 400 != 0:
        return False
    else:
        return True

class Arc(object):
    def __init__(self):
        self.left = []
        count = 0
        for year in range(400):
            self.left.append(count)
            if isLeapYear(year):
                count += 366
            else:
                count += 365
        self.monthOffset = [
            0, 31, 59, 90,
            120, 151, 181, 212,
            243, 273, 304, 334
            ]
        self.monthOffsetLeap = [
            0, 31, 60, 91,
            121, 152, 182, 213,
            244, 274, 305, 335
            ]
    def find_year(self,index):
        small = 0
        big = 399
        while big - small > 1:
            med = (big + small) // 2
            if self.left[med] == index:
                return med
            if self.left[med] > index:
                big = med
            else:
                small = med
        if index < self.left[big]:
            return small
        else:
            return big
    def find_month(self,index,array):
        small = 0
        big = 11
        while big - small > 1:
            med = (big + small) // 2
            if array[med] == index:
                return med
            if array[med] > index:
                big = med
            else:
                small = med
        if index < array[big]:
            return small
        else:
            return big
    def get_date(self,index):
        year = self.find_year(index)
        index -= self.left[year]
        if isLeapYear(year):
            monthArray = self.monthOffsetLeap
        else:
            monthArray = self.monthOffset
        month = self.find_month(index,monthArray)
        index -= monthArray[month]
        return [year,month+1,index+1]
    def encode_date(self,year,month,day):
        year %= 400
        month -= 1
        day -= 1
        if isLeapYear(year):
            return self.left[year] + self.monthOffsetLeap[month] + day
        else:
            return self.left[year] + self.monthOffset[month] + day

def main():
    arc = Arc()
    s = arc.encode_date(1999,12,31)
    print(s)
    j = arc.get_date(s)
    print(j)

main()