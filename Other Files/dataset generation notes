1️⃣ Start with BUSINESS LOGIC, not tables

If you start by thinking in CSVs, you already lost.

You must first define:

How customers enter

How they buy

How marketing influences behavior

How seasonality affects everything

Order of generation must be:

Time calendar & seasonality

Marketing campaigns & spend

Website sessions (traffic reaction)

Customers (signup → lifecycle)

Orders (behavior-driven, not random)

If you generate customers or orders before this flow, the data will be incoherent.

2️⃣ Temporal integrity (this is sacred)

Every single time-based relationship must hold:

signup_date ≤ first_order_date

order_date ≤ repeat_order_date

marketing_spend.date → session_date → order_date

No future data leaks. Ever.

Interviewers test this silently. One violation = dataset dismissed.

3️⃣ Customer behavior must be emergent, not labeled

Rules you must enforce:

customer_type is derived, never assigned

Returning customers:

Order more often

Convert more easily

Skew revenue disproportionately

New customers:

Higher drop-off

Longer time-to-first-order

If customer behavior doesn’t naturally produce these outcomes, the dataset is fake.

4️⃣ Channels must MEAN something

Every channel needs a personality.

You must hard-code differences like:

Email:

Highest conversion rate

Highest AOV

Lower volume

Paid Search:

High spend

Lower margin

Discount-heavy

Organic:

Stable volume

Medium conversion

Social:

Volatile traffic

Lowest conversion

Spiky campaigns

If channel metrics overlap heavily, attribution analysis becomes pointless.

5️⃣ Seasonality must be obvious, not subtle

Do NOT be afraid of strong signals.

Required patterns:

November → extreme spike

December → sustained peak

January–February → visible drop

June–July → secondary peak

An interviewer should see this in a simple monthly line chart without squinting.

6️⃣ Marketing spend must drive everything downstream

This is where most synthetic datasets fail.

You must ensure:

Spend spikes → session spikes

Session spikes → conversion lifts

Campaign periods → higher conversion probability

If sessions or orders don’t react to spend, the dataset is broken.

7️⃣ Conversion logic must be probabilistic, not uniform

Rules:

Conversion rate differs by channel

Conversion rate increases during campaigns

Conversion rate increases with customer tenure

Overall conversion remains realistically low

Flat conversion = amateur data.

8️⃣ Quantity, pricing, and revenue realism

You need controlled skew, not randomness:

Quantity:

Mostly 1

Some 2

Rare 3+

Pricing:

Category-driven base prices

Channel-driven discounts

Seasonal discounting

Revenue:

Explainable outliers

Rare extreme values

No uniform noise

If revenue can’t be explained, it looks fake.

9️⃣ Data messiness (deliberate, controlled)

Real data is annoying. Yours should be too — but not broken.

Include:

Inconsistent channel naming

Missing marketing_spend days

Zero-spend days

Rare extreme values

But:

Never break joins

Never violate time logic

Never create ambiguity in keys

Messy ≠ sloppy.

🔟 Scale must support analysis, not impress

Avoid vanity row counts.

Target:

Enough data for cohort curves

Enough volume for channel splits

Enough history for YoY comparisons

If a Power BI dashboard feels “thin”, you underbuilt it.

1️⃣1️⃣ Ask one brutal question before finalizing

Before you ship the dataset, ask:

“If an interviewer asks why this happened, can I explain it without hand-waving?”

If the answer is no, regenerate.

Final truth

An interview-ready dataset is not about realism alone.
It’s about causality, constraints, and consistency.

When reviewed, the reviewer should think:

“This person understands how businesses actually work.”

If they think:

“This looks generated”

—you failed.