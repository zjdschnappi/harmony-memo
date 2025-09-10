/**
 * 格式化日期为指定格式
 * @param {Date} date - 需要格式化的日期对象
 * @param {string} format - 格式化字符串 (默认: 'YYYY-MM-DD HH:mm:ss')
 * @returns {string} 格式化后的日期字符串
 */
export  function formatDate(date:Date, format = 'YYYY-MM-DD HH:mm:ss') {
  const padZero = (num) => num.toString().padStart(2, '0');

  const year = date.getFullYear().toString();
  const month = padZero(date.getMonth() + 1); // 月份从0开始
  const day = padZero(date.getDate());
  const hours = padZero(date.getHours());
  const minutes = padZero(date.getMinutes());
  const seconds = padZero(date.getSeconds());

  // 替换占位符
  return format
    .replace('YYYY', year)
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hours)
    .replace('mm', minutes)
    .replace('ss', seconds);
}


class DateTimeBase {
  public hourRange(): string[] {
    return this.range(0, 23, '时');
  }

  public minutesRange(): string[] {
    return this.range(0, 59, '分');
  }

  public secondsRange(): string[] {
    return this.range(0, 59, '秒');
  }

  public range(start: number, end: number, unit: string): string[] {
    let min = (start > end) ? end : start;
    let max = (start > end) ? start : end;

    let range: string[] = [];
    for (let i = min; i <= max; i++) {
      range.push(i.toString() + unit);
    }
    return range;
  }

  public isLeapYear(year: number): boolean {
    if ((year % 400 === 0) ||
      (year % 4 === 0 && year % 100 !== 0)) {
      return true;
    }
    return false;
  }
}
export class DateTimeSolar extends DateTimeBase {
  private startYear: number = 0;
  private endYear: number = 0;

  public setYearRange(startYear: number, endYear: number) {
    let minYear = (startYear > endYear) ? endYear : startYear;
    let maxYear = (startYear > endYear) ? startYear : endYear;

    this.startYear = minYear;
    this.endYear = maxYear;
  }

  public getStartSolarYear(): number {
    return this.startYear;
  }

  public yearRange(): string[] {
    return this.range(this.startYear, this.endYear, '年');
  }

  public monthRange(): string[] {
    return this.range(1, 12, '月');
  }

  public dayRange(year: number, month: number): string[] {
    let mapDays = new Map<number, number>([
      [1, 31], [2, this.isLeapYear(year) ? 29 : 28], [3, 31], [4, 30], [5, 31], [6, 30],
      [7, 31], [8, 31], [9, 30], [10, 31], [11, 30], [12, 31]
    ]);

    return this.range(1, mapDays.get(month) ?? 30, '日');
  }
}

class DateTimeRangeClass {
  readonly dateTimeSolar: DateTimeSolar = new DateTimeSolar();

  public getSolar(): DateTimeSolar {
    return this.dateTimeSolar;
  }

  public getStartYear() {
    return this.dateTimeSolar.getStartSolarYear();
  }

  public setYearRange(startYear: number, endYear: number): void {
    this.dateTimeSolar.setYearRange(startYear, endYear);
  }

  public yearRange(): string[] {
    return this.dateTimeSolar.yearRange();
  }

  public monthRange(year: number): string[] {
    return this.dateTimeSolar.monthRange();
  }

  public dayRange(year: number, month: number): string[] {
    return this.dateTimeSolar.dayRange(year, month);
  }

  public hourRange(): string[] {
    return this.dateTimeSolar.hourRange();
  }

  public minutesRange(): string[] {
    return this.dateTimeSolar.minutesRange();
  }

  public secondsRange(): string[] {
    return this.dateTimeSolar.secondsRange();
  }
}

export const DATE_TIME_RANGE = new DateTimeRangeClass();

