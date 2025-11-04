function toDate(d) {
  if (d instanceof Date) return d;
  if (typeof d === 'string' || typeof d === 'number') {
    const x = new Date(d);
    if (Number.isNaN(x.getTime())) {
      throw new Error(`Invalid date input: ${d}`);
    }
    return x;
  }
  throw new Error(`Unsupported date type: ${typeof d}`);
}
module.exports = {
  toDate
};