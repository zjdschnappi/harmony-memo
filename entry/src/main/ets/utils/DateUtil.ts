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