const { toDate } = require('../utils/date');
/**
 * Check if two time ranges [aStart, aEnd) and [bStart, bEnd) overlap.
 * End is treated as exclusive boundary.
 */
function isOverlap(aStart, aEnd, bStart, bEnd) {
  const A1 = toDate(aStart);
  const A2 = toDate(aEnd);
  const B1 = toDate(bStart);
  const B2 = toDate(bEnd);

  if (A2 <= A1) throw new Error('Range A end must be after start');
  if (B2 <= B1) throw new Error('Range B end must be after start');

  return (A1 < B2) && (B1 < A2);
}

/**
 * Check a candidate range against a list of existing ranges.
 * Each existing item should have { start_dt: Date|string|number, end_dt: Date|string|number }
 * Returns the first conflicting item (or null if no conflict).
 */
function findFirstOverlap(candidateStart, candidateEnd, existingList) {
  const A1 = toDate(candidateStart);
  const A2 = toDate(candidateEnd);

  for (const item of existingList || []) {
    const B1 = toDate(item.start_dt);
    const B2 = item.end_dt ? toDate(item.end_dt) : null;

    // If end_dt is null (e.g. REPAIR chưa chẩn đoán), assume a 60-min window
    const _B2 = B2 || new Date(B1.getTime() + 60 * 60 * 1000);

    if (isOverlap(A1, A2, B1, _B2)) return item;
  }
  return null;
}

/** Utility: add minutes to a date (returns new Date) */
function addMinutes(dateLike, minutes) {
  const d = toDate(dateLike);
  return new Date(d.getTime() + minutes * 60 * 1000);
}

module.exports = {
  isOverlap,
  findFirstOverlap,
  addMinutes
};