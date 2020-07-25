--Question 1.
--Total number of Wave Users
SELECT COUNT (u_id)
FROM users;

--OR

SELECT COUNT (u_id)
AS wave_users
FROM users;

--Question 2.
--Transfers sent in the currency CFA.
SELECT COUNT (transfer_id)
AS transfers_in_cfa
WHERE send_amount_currency = 'CFA';

--Question 3.
--Number of different users who sent a tranfer in CFA.
SELECT COUNT (DISTINCT u_id)
FROM transfers
WHERE send_amount_currency = 'CFA';

--Question 4.
--Number of agent transactions had in the month of 2018.
SELECT COUNT (atx_id)
FROM agent_transactions
WHERE EXTRACT(YEAR FROM when_created)=2018
GROUP BY EXTRACT (MONTH FROM when_created);


-- Question 5.
--Weekly report on agents who were net_withdrawers and agents who were net_depositors
SELECT SUM(CASE WHEN amount > 0 THEN amount else 0 END)
AS withdrawal,
SUM(CASE WHEN amount < 0 then amount else 0 END)
AS deposit,
CASE WHEN ((SUM(CASE WHEN amount > 0
THEN amount else 0 END)) > ((SUM(CASE WHEN amount < 0 then amount else 0 END))) * -1)
THEN 'withdrawer'
ELSE 'depositor'
END as agent_status,
COUNT (*) FROM agent_transactions
WHERE when_created
BETWEEN (now() - '1 week'::INTERVAL)
AND now();

--Question 6.
--atx volume city summary for one week
SELECT agents.city,
COUNT (amount) AS "atx volume city summary"
FROM agent_transactions
INNER JOIN agents
ON agents.agent_id = agent_transactions.agent_id
WHERE agent_transactions.when_created
BETWEEN (NOW() - '1 week'::INTERVAL)
AND NOW()
GROUP BY agents.city;

--Question 7.
--atx volume by country
SELECT COUNT(atx.amount) AS "atx_volumn",
COUNT (agents.city) AS "city",
COUNT (agents.country) AS "country"
FROM agent_transactions AS atx
INNER JOIN agents
ON atx.atx_id = agents.agent_id
GROUP BY agents.country;

--Question 8.
--table by country, transfer kind and volumn.
SELECT wallets.ledger_location
AS "Country", agent_transactions.send_amount_currency
AS "Transfer_Kind",
SUM (agent_transactions.send_amount_scalar)
AS "Volume"
FROM transfers
AS agent_transactions
INNER JOIN wallets
ON agent_transactions.transfer_id = wallets.wallet_id
WHERE agent_transactions.when_created = CURRENT_DATE - INTERVAL '1 week'
GROUP BY wallets.ledger_location, agent_transactions.send_amount_currency;


--Question 9.
--columns for transaction kind and number of unique senders.
SELECT COUNT(transfers.source_wallet_id)
AS Unique_Senders,
COUNT (transfer_id)
AS Transaction_Count, transfers.kind
AS Transfer_Kind, wallets.ledger_location
AS Country,
SUM (transfers.send_amount_scalar)
AS Volume
FROM transfers
INNER JOIN wallets
ON transfers.source_wallet_id = wallets.wallet_id
WHERE (transfers.when_created > (NOW() - INTERVAL '1 week'))
GROUP BY wallets.ledger_location, transfers.kind;

--Question 10.
--wallets that have sent more than 10000000 CFA in the last MONTHSELECT users.u_id, transfers.send_amount_scalar, transfers.when_created
SELECT source_wallet_id, send_amount_scalar
FROM transfers AS "total_transfers"
WHERE send_amount_currency = 'CFA'
AND (send_amount_scalar > 10000000)
AND (total_transfers.when_created) > CURRENT_DATE - INTERVAL '1 month';
