SELECT
    acc.branch_id,
    acc.number_of_customers,
    acc.number_of_accounts,
    acc.total_balance,
    COALESCE(ln.total_loan_issued, 0) AS total_loan_issued,
    COALESCE(txn.number_of_transactions, 0) AS number_of_transactions,
    RANK() OVER (
        ORDER BY acc.total_balance DESC, acc.number_of_customers DESC
    ) AS branch_rank
FROM (
    SELECT
        branch_id,
        COUNT(DISTINCT customer_id) AS number_of_customers,
        COUNT(DISTINCT account_id) AS number_of_accounts,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY branch_id
) acc
LEFT JOIN (
    SELECT branch_id, COUNT(*) AS total_loan_issued
    FROM loans
    GROUP BY branch_id
) ln ON acc.branch_id = ln.branch_id
LEFT JOIN (
    SELECT a.branch_id, COUNT(t.transaction_id) AS number_of_transactions
    FROM accounts a
    JOIN transactions t ON t.account_id = a.account_id
    GROUP BY a.branch_id
) txn ON acc.branch_id = txn.branch_id
ORDER BY branch_rank;
