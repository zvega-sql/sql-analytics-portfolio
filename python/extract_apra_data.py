"""
Extracts data from APRA AMCOS royalty statement and remittance advice PDFs.

Part 1: Royalty Statements -> Period + Net Royalty Total
Part 2: Remittance Advices -> Period + Payment (AU$)
Both parts write/merge into a single CSV: Period, AUD PDF, Remittance

Requires: pdftotext (poppler-utils) on PATH.
"""
import re, csv, glob, os

MONTHS = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04', 'May': '05', 'Jun': '06',
    'Jul': '07', 'Aug': '08', 'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
}

# ---------------------------------------------------------------------------
# PART 1: Royalty statements (page 1 only) -> Period, Net Royalty Total
# ---------------------------------------------------------------------------

def extract_statements(pdf_dir):
    rows = []
    errors = []

    for path in sorted(glob.glob(os.path.join(pdf_dir, '*.pdf'))):
        fname = os.path.basename(path)
        # Only page 1 needed -- keeps this cheap even for large batches
        text = os.popen(f'pdftotext -f 1 -l 1 "{path}" -').read()

        total_m = re.search(r'Net Royalty Total:\s*AU\s*\$([\d,]+\.\d{2})', text)
        period_m = re.search(r'Period:\s*(\w{3})\s*(\d{4})', text)

        if not total_m or not period_m:
            errors.append(fname)
            continue

        amount = float(total_m.group(1).replace(',', ''))
        mon, yr = period_m.group(1), period_m.group(2)
        period_str = f"{yr} {MONTHS[mon]}"

        rows.append((period_str, amount, fname))

    rows.sort(key=lambda r: r[0])
    if errors:
        print(f"Statement extraction FAILED for: {errors}")
    return rows


# ---------------------------------------------------------------------------
# PART 2: Remittance advices (full document, may span many pages)
#          -> Period (from filename), Payment AU$ (from summary row)
# ---------------------------------------------------------------------------

FNAME_RE = re.compile(r'_(?:\d{1,2})?([A-Z][a-z]{2})(\d{4})\.pdf$')
# Anchored to start of line so it only matches the summary "Payment" row,
# not transaction descriptions like "Fast Track Payment" (those start with a date).
PAYMENT_RE = re.compile(r'^\s*Payment\s+-?\$?([\d,]+\.\d{2})\s+(-?)\$?([\d,]+\.\d{2})\s*$', re.MULTILINE)

def extract_remittances(pdf_dir):
    remit = {}
    unparsed = []

    for path in sorted(glob.glob(os.path.join(pdf_dir, '*.pdf'))):
        fname = os.path.basename(path)
        m = FNAME_RE.search(fname)
        if not m:
            unparsed.append(fname)
            continue
        mon, yr = m.group(1), m.group(2)
        period = f"{yr} {MONTHS[mon]}"

        # No page range limit -- the Payment summary row is on the last page
        text = os.popen(f'pdftotext -layout "{path}" -').read()
        pm = PAYMENT_RE.search(text)
        if not pm:
            unparsed.append(fname)
            continue

        sign = '-' if pm.group(2) == '-' else ''
        amount = float(sign + pm.group(3).replace(',', ''))
        remit[period] = (amount, fname)

    if unparsed:
        print(f"Remittance extraction FAILED for: {unparsed}")
    return remit


# ---------------------------------------------------------------------------
# Merge and write final CSV
# ---------------------------------------------------------------------------

def main(statement_dir, remittance_dir, out_csv):
    statement_rows = extract_statements(statement_dir)
    remit = extract_remittances(remittance_dir)

    with open(out_csv, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Period', 'AUD PDF', 'Remittance'])
        for period_str, amount, _fname in statement_rows:
            remit_val = remit[period_str][0] if period_str in remit else ''
            w.writerow([period_str, amount, remit_val])

    print(f"Wrote {len(statement_rows)} rows to {out_csv}")


if __name__ == '__main__':
    main(
        statement_dir='/home/claude/pdfs',
        remittance_dir='/home/claude/remit',
        out_csv='/home/claude/final_output.csv',
    )
