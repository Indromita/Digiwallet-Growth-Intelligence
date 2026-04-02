# Digiwallet Growth Intelligence: User Retention & Churn Analysis

## Project Overview
Data driven diagnosis of a digital wallet company to better understand its leaky bucket scenario and recommend future steps for growth.

## Dashboard
<img width="1363" height="768" alt="image" src="https://github.com/user-attachments/assets/671eecc8-3376-40bc-88a4-784273e828cb" />
<img width="1361" height="771" alt="image" src="https://github.com/user-attachments/assets/66e53724-bf3d-464b-8776-7f07db8f3eec" />


### 1. Problem Statement
A digital Wallet company facing the Leaky Bucket situation needing a diagnosis on where the leak really is. The volume and the long term effects of it are required to be addressed and recommendations given regarding its future processes. 
Challenge uncovered- DigiWallet faces a critical 77% user churn rate, with 3,029 users out of 3932 failing to return after their initial transaction. The primary business challenge was to identify if high service fees were driving attrition or if deeper behavioral factors were at play.

### 2. Data & Methodology
Data Source: 5000 anonymised transactions records spanning over 20 product categories for one financial year.

Tools: 1) Advanced SQL (CTEs, Joins, Aggregations) for data cleaning and analysis 
           2) Power BI (DAX, Interactive Dashboards) for analysis and visualization.
           3) LLM(Gemini)

Methodologies: 
Exploratory Data Analysis (EDA)- Discovering negative margins and flagging fee efficiency fallbacks.
User Segmentation & Churn Analysis- For behavioural analysis to understand Aha! Moments and for a deep dive on Churn vs Retention.  
Cohort Analysis- Forming comparison groups based on engagement and tracking the Absolute time(for the apps lifecycle) and the relative time of the users (for LTV calculation).
Unit Economics- Evaluating the Average Fee per Transaction to ensure the pricing model remains sustainable while remaining competitive.
Feature Adoption & Root cause analysis: Tracking how users transitioned from "Entry" categories (Education) to "Habit" categories (Utilities/Recharge) and why. 

### 3. Key Insights
The Fee Myth: Analysis proved fees are not the driver of churn. Both groups paid near-identical average fees. This indicates that price optimization has already been achieved.

The ₹5,000 Trust Threshold: A clear Positive Correlation exists between transaction value and retention. Users crossing the ₹5,000 mark (retained users) show significantly higher repeat rates than those below that mark, especially the ones using the app for the first time for very small transaction amounts (eg, water billings).

Product Category Overlap & Divergence: While both groups( churned vs retained) include "Education fee" and "Hotel bookings," Repeat users spend 12% more in these categories than the churned users. Generally, the retained users use the app to pay for  product categories which are more expensive as opposed to the churned users. This indicates trust in the app for big value transactions. 

### 4. Actionable Recommendations
Market Value- Building on high value product categories will help draw in more users. Marketing the app as a high trust digital wallet that allows for big money transactions.

The Habit nudge: Automating cross-sell notifications for Utilities and Recharge immediately following high-ticket "Entry" transactions might make people stay even for the low value transactions.

Customer and onboarding fixes- Customer inputs and simplifying onboarding through simple processes and instruction manuals to guide users to their first Aha! moment. The next big objective would be reaching the break even point (at 16 transactions).

### 5. Potential Impact
Revenue: Shifting 5% of the current churned cohort (150 users) to the 4 time transaction cohort  results in a projected ₹30,00,000 increase in Gross Transaction Value (GTV).

Unit Economics Optimization: By successfully nudging users past the ₹5,000 Trust Threshold  the revenue per user increases from a one-time ₹25 fee to a lifetime value (LTV) of ₹400+, a 16x growth in profitability.

Market Positioning: By addressing the market fit problem, high value categories, the platform can reduce customer acquisition costs (CAC) by focusing on high-intent users who align with the Aha! Moment of high value transaction.

