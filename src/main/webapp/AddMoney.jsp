<%@page import="mvc_olx.dto.Customer"%>
<%@page import="mvc_olx.helper.CurrencyFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Money – OLX Wallet</title>
    <meta name="description" content="Top up your OLX Wallet to buy products on the marketplace.">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/styles.css">
    <style>
        .balance-display {
            background: linear-gradient(135deg, rgba(16,185,129,0.15), rgba(6,95,70,0.1));
            border: 1px solid rgba(16,185,129,0.3);
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            margin-bottom: 24px;
        }
        .balance-label { font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 6px; }
        .balance-amount {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--success);
        }
        .quick-amounts {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 8px;
        }
        .quick-btn {
            padding: 8px 16px;
            border: 1px solid var(--card-border);
            border-radius: 999px;
            background: rgba(255,255,255,0.05);
            color: var(--text-secondary);
            cursor: pointer;
            font-family: inherit;
            font-size: 0.9rem;
            font-weight: 500;
            transition: var(--transition);
        }
        .quick-btn:hover {
            border-color: var(--success);
            color: var(--success);
            background: rgba(16,185,129,0.1);
        }
        .add-form { display: flex; gap: 12px; align-items: flex-end; }
        .add-form .form-group { flex: 1; display: flex; flex-direction: column; gap: 6px; }
        .input-icon-wrap { position: relative; }
        .input-icon-wrap .icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%); font-weight: 700; color: var(--success); font-size: 1.1rem;
        }
        .input-icon-wrap input { padding-left: 36px; }
        .field-error { font-size: 0.82rem; color: #f87171; display: none; margin-top: 2px; }
        .input-invalid { border-color: #ef4444 !important; box-shadow: 0 0 0 3px rgba(239,68,68,0.15) !important; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <div class="page" style="max-width: 520px;">
        <%
        Customer customer = (Customer)session.getAttribute("customer");
        if(customer == null) {
        %>
            <div class="card">
                <div class="message message-error">⚠️ Please log in to add money to your wallet.</div>
                <a href="Login.jsp" class="btn btn-primary btn-block">Go to Login</a>
            </div>
        <% } else { %>
            <div class="card">
                <h1>Add Money 💰</h1>
                <p class="subtitle">Top up your OLX Wallet instantly.</p>

                <div class="balance-display">
                    <div class="balance-label">Current Wallet Balance</div>
                    <div class="balance-amount"><%= CurrencyFormatter.format(customer.getWallet()) %></div>
                </div>

                <label style="margin-bottom:10px;display:block">Quick Add</label>
                <div class="quick-amounts">
                    <button class="quick-btn" type="button" onclick="setAmount(100)">+ ₹100</button>
                    <button class="quick-btn" type="button" onclick="setAmount(500)">+ ₹500</button>
                    <button class="quick-btn" type="button" onclick="setAmount(1000)">+ ₹1,000</button>
                    <button class="quick-btn" type="button" onclick="setAmount(5000)">+ ₹5,000</button>
                </div>

                <form action="addmoney" method="get" id="addMoneyForm" novalidate style="margin-top:16px">
                    <div class="add-form">
                        <div class="form-group">
                            <label for="money">Custom Amount</label>
                            <div class="input-icon-wrap">
                                <span class="icon">₹</span>
                                <input type="number" id="money" name="money" step="0.01" min="1" placeholder="Enter amount" required>
                            </div>
                            <span class="field-error" id="money-error">Please enter a valid amount (min ₹1).</span>
                        </div>
                        <button type="submit" class="btn btn-success" style="flex-shrink:0;height:52px;padding:0 24px;">Add →</button>
                    </div>
                </form>

                <div style="margin-top: 20px; display: flex; gap: 12px;">
                    <a href="wallet" class="btn btn-secondary" style="flex:1">View Wallet</a>
                    <a href="Home.jsp" class="btn btn-secondary" style="flex:1">← Home</a>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        function setAmount(val) {
            document.getElementById('money').value = val;
            document.getElementById('money').focus();
        }

        document.getElementById('addMoneyForm')?.addEventListener('submit', function(e) {
            const money = document.getElementById('money');
            const err = document.getElementById('money-error');
            err.style.display = 'none';
            money.classList.remove('input-invalid');
            if (!money.value || parseFloat(money.value) < 1) {
                err.style.display = 'block';
                money.classList.add('input-invalid');
                e.preventDefault();
            }
        });
    </script>
</body>
</html>
