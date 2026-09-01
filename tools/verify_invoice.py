#!/usr/bin/env python3
"""
verify_invoice.py — تحقق بكسلي آلي: الفاتورة المولَّدة مقابل الفاتورة الورقية الأصلية.

الاستخدام:
    flutter test test/pdf_render_probe.dart      # يُنتج /tmp/probe/out.pdf
    python3 tools/verify_invoice.py

يقيس ويقارن:
  • الخطوط الأفقية (الموضع، السماكة، المدى الأفقي)
  • النطاق الخوخي لرأس الجدول
  • الخطوط الرأسية للجدول وعروض الأعمدة
  • نطاقات الحبر (كل سطر نص)
ويطبع خطأً مطلقاً متوسطاً (MAE) لكل مجموعة.
"""

from __future__ import annotations

import os
import sys

import numpy as np
from PIL import Image

REF = os.environ.get("REF_PNG", "/tmp/cmp/ref.png")
PDF = os.environ.get("PROBE_PDF", "/tmp/probe/out.pdf")
CUR = "/tmp/probe/cur1024.png"

REF_W = 1024  # عرض الصورة المرجعية بالبكسل


def render_pdf_to_ref_width(pdf_path: str, out_png: str) -> None:
    """يرندر الصفحة الأولى بحيث يصبح عرضها 1024px — نفس مقياس الأصل."""
    import pymupdf

    doc = pymupdf.open(pdf_path)
    page = doc[0]
    s = REF_W / page.rect.width
    pm = page.get_pixmap(matrix=pymupdf.Matrix(s, s))
    Image.frombytes("RGB", (pm.width, pm.height), pm.samples).save(out_png)


def load(path: str):
    img = Image.open(path).convert("RGB")
    gray = np.asarray(img.convert("L")).astype(np.int16)
    return img, gray, gray < 150


def h_rules(dark, min_frac=0.40):
    """الخطوط الأفقية: صفوف يغطي فيها الحبر نسبة كبيرة من العرض."""
    h, w = dark.shape
    rows = dark.sum(axis=1)
    out, inr, st = [], False, 0
    for y in range(h):
        hit = rows[y] >= min_frac * w
        if hit and not inr:
            st, inr = y, True
        elif not hit and inr:
            xs = np.where(dark[st:y].any(axis=0))[0]
            out.append((st, y - 1, y - st, int(xs.min()), int(xs.max())))
            inr = False
    return out


def peach_band(img, y_from=250):
    """نطاق رأس الجدول الخوخي.

    ⚠️ يُقيَّد بما دون y=250 لأن قرص الشعار برتقالي ويلوّث القناع.
    """
    rgb = np.asarray(img).astype(int)
    m = (
        (np.abs(rgb[:, :, 0] - 252) < 22)
        & (np.abs(rgb[:, :, 1] - 213) < 26)
        & (np.abs(rgb[:, :, 2] - 180) < 28)
    )
    m[:y_from, :] = False
    ys, xs = np.where(m)
    if not len(ys):
        return None
    return int(ys.min()), int(ys.max()), int(xs.min()), int(xs.max())


def v_rules(dark, y0, y1, frac=0.60):
    band = dark[y0 : y1 + 1]
    cols = band.sum(axis=0)
    thr = frac * band.shape[0]
    out, inr, st = [], False, 0
    for x in range(dark.shape[1]):
        hit = cols[x] >= thr
        if hit and not inr:
            st, inr = x, True
        elif not hit and inr:
            out.append((st + x - 1) // 2)
            inr = False
    return out


def ink_bands(dark, ylim, min_h=3, min_px=6):
    rows = dark.sum(axis=1)
    out, inr, st = [], False, 0
    for y in range(min(ylim, dark.shape[0])):
        hit = rows[y] >= min_px
        if hit and not inr:
            st, inr = y, True
        elif not hit and inr:
            if y - st >= min_h:
                xs = np.where(dark[st:y].any(axis=0))[0]
                out.append((st, y - 1, int(xs.min()), int(xs.max())))
            inr = False
    return out


def match_nearest(ref, cur, tol=26):
    """يزاوج نطاقات الحبر بأقرب موضع رأسي لا بالفهرس.

    ضروري لأن اكتشاف النطاقات يندمج/ينفصل حسب جودة المسح،
    فالمزاوجة بالفهرس تقارن عناصر مختلفة تماماً.
    """
    used, pairs = set(), []
    for a in ref:
        best, bd = None, 10**9
        for j, b in enumerate(cur):
            if j in used:
                continue
            d = abs(b[0] - a[0])
            if d < bd:
                best, bd = j, d
        if best is not None and bd <= tol:
            used.add(best)
            pairs.append((a, cur[best]))
        else:
            pairs.append((a, None))
    for j, b in enumerate(cur):
        if j not in used:
            pairs.append((None, b))
    return pairs


def report(name, ref, cur, fmt):
    print(f"\n───── {name} ─────")
    n = min(len(ref), len(cur))
    if len(ref) != len(cur):
        print(f"  ⚠️  عدد العناصر مختلف: أصل={len(ref)}  حالي={len(cur)}")
    errs = []
    for i in range(n):
        line, e = fmt(ref[i], cur[i])
        print(f"  {i}: {line}")
        errs.extend(e)
    if errs:
        mae = sum(abs(v) for v in errs) / len(errs)
        worst = max(errs, key=abs)
        flag = "✅" if mae <= 2.0 else ("🟡" if mae <= 4.0 else "❌")
        print(f"  {flag} MAE = {mae:.2f}px   أسوأ انحراف = {worst:+d}px")
        return mae
    return 0.0


def main() -> int:
    if not os.path.exists(PDF):
        print(f"✗ لا يوجد {PDF} — شغّل: flutter test test/pdf_render_probe.dart")
        return 2
    if not os.path.exists(REF):
        print(f"✗ لا توجد الصورة المرجعية {REF}")
        return 2

    render_pdf_to_ref_width(PDF, CUR)
    rimg, _, rdark = load(REF)
    cimg, _, cdark = load(CUR)
    print(f"الأصل  : {rimg.size[0]}×{rimg.size[1]}")
    print(f"المولَّد: {cimg.size[0]}×{cimg.size[1]}  (مقيس إلى عرض الأصل)")

    maes = []

    # 1) الخطوط الأفقية
    maes.append(
        report(
            "الخطوط الأفقية (y، السماكة، المدى)",
            h_rules(rdark),
            h_rules(cdark),
            lambda a, b: (
                f"y {a[0]:4d}→{b[0]:4d} (Δ{b[0]-a[0]:+4d})  "
                f"t {a[2]}→{b[2]}  "
                f"x {a[3]:4d}..{a[4]:4d} → {b[3]:4d}..{b[4]:4d} "
                f"(Δيسار {b[3]-a[3]:+4d}، Δيمين {b[4]-a[4]:+4d})",
                [b[0] - a[0], b[3] - a[3], b[4] - a[4]],
            ),
        )
    )

    # 2) النطاق الخوخي
    rp, cp = peach_band(rimg), peach_band(cimg)
    print("\n───── نطاق رأس الجدول الخوخي ─────")
    if rp and cp:
        print(f"  الأصل  : y {rp[0]}..{rp[1]}  x {rp[2]}..{rp[3]}")
        print(f"  المولَّد: y {cp[0]}..{cp[1]}  x {cp[2]}..{cp[3]}")
        d = [cp[i] - rp[i] for i in range(4)]
        mae = sum(abs(v) for v in d) / 4
        print(f"  {'✅' if mae<=2 else '🟡' if mae<=4 else '❌'} Δ={d}  MAE={mae:.2f}px")
        maes.append(mae)

    # 3) الخطوط الرأسية للجدول
    if rp and cp:
        rv = v_rules(rdark, rp[0], rp[1] + 42)
        cv = v_rules(cdark, cp[0], cp[1] + 42)
        print("\n───── الخطوط الرأسية للجدول ─────")
        print(f"  الأصل  : {rv}")
        print(f"  المولَّد: {cv}")
        if len(rv) == len(cv) and len(rv) > 1:
            hdr = [
                "المبلغ المستحق",
                "مدفوع خلال الفترة",
                "المتأخرات",
                "خدمات",
                "القيمة",
                "الاستهلاك",
                "القراءة الحالية",
                "القراءة السابقة",
            ]
            rw = [rv[i + 1] - rv[i] for i in range(len(rv) - 1)]
            cw = [cv[i + 1] - cv[i] for i in range(len(cv) - 1)]
            errs = []
            for i, (a, b) in enumerate(zip(rw, cw)):
                errs.append(b - a)
                label = hdr[i] if i < len(hdr) else ""
                print(f"    عمود {i}: {a:4d} → {b:4d}  Δ{b-a:+4d}   {label}")
            mae = sum(abs(v) for v in errs) / len(errs)
            print(
                f"  {'✅' if mae<=2 else '🟡' if mae<=4 else '❌'} "
                f"عرض الجدول: {rv[-1]-rv[0]} → {cv[-1]-cv[0]}   MAE أعمدة = {mae:.2f}px"
            )
            maes.append(mae)

    # 4) نطاقات الحبر
    print("\n───── نطاقات الحبر (مزاوجة بأقرب موضع) ─────")
    pairs = match_nearest(ink_bands(rdark, 470), ink_bands(cdark, 470))
    errs = []
    for a, b in pairs:
        if a is None:
            print(f"  ➕ زائد في المولَّد: y {b[0]:4d}..{b[1]:4d}  x {b[2]:4d}..{b[3]:4d}")
            continue
        if b is None:
            print(f"  ➖ مفقود في المولَّد: y {a[0]:4d}..{a[1]:4d}  x {a[2]:4d}..{a[3]:4d}")
            continue
        errs += [b[0] - a[0], b[2] - a[2], b[3] - a[3]]
        print(
            f"  y {a[0]:4d}→{b[0]:4d} (Δ{b[0]-a[0]:+4d})  "
            f"x {a[2]:4d}..{a[3]:4d} → {b[2]:4d}..{b[3]:4d} "
            f"(Δيسار {b[2]-a[2]:+4d}، Δيمين {b[3]-a[3]:+4d})"
        )
    if errs:
        mae = sum(abs(v) for v in errs) / len(errs)
        print(
            f"  {'✅' if mae<=3 else '🟡' if mae<=8 else '❌'} "
            f"MAE = {mae:.2f}px   أسوأ انحراف = {max(errs, key=abs):+d}px"
        )
        maes.append(mae)

    print("\n" + "═" * 62)
    overall = sum(maes) / len(maes) if maes else 0
    verdict = "✅ ممتاز" if overall <= 2 else "🟡 مقبول" if overall <= 4 else "❌ يحتاج ضبطاً"
    print(f"  الخطأ الكلي المتوسط = {overall:.2f}px   ⇒   {verdict}")
    print("═" * 62)
    return 0


if __name__ == "__main__":
    sys.exit(main())
