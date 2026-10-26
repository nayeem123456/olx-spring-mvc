<%@page import="mvc_olx.dto.Customer"%>
<%@page import="mvc_olx.helper.CurrencyFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wallet – OLX Marketplace</title>
    <meta name="description" content="View and manage your OLX Wallet balance. Add money and track transactions.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .wallet-hero {
            background: linear-gradient(135deg, rgba(16,185,129,0.12), rgba(139,92,246,0.08));
            border: 1px solid rgba(16,185,129,0.22);
            border-radius: 18px;
            padding: 36px 24px;
            text-align: center;
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
        }
        [data-theme="light"] .wallet-hero {
            background: linear-gradient(135deg, #F0FDF4, #EDE9FE);
            border-color: #BBF7D0;
        }
        .wallet-hero::before {
            content: '💰';
            position: absolute;
            font-size: 7rem;
            opacity: 0.06;
            top: -5px; right: 10px;
            user-select: none;
            pointer-events: none;
        }
        .wallet-label {
            font-size: 0.78rem;
            color: var(--text-muted);
            letter-spacing: 0.6px;
            text-transform: uppercase;
            margin-bottom: 10px;
            font-weight: 700;
        }
        .wallet-amount {
            font-size: 3.4rem;
            font-weight: 800;
            color: var(--success);
            line-height: 1.1;
            margin-bottom: 8px;
        }
        [data-theme="light"] .wallet-amount { color: #059669; }
        .wallet-note {
            font-size: 0.84rem;
            color: var(--text-secondary);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 22px;
        }
        .stat-card {
            background: var(--secondary-bg);
            border: 1px solid var(--card-border);
            border-radius: 14px;
            padding: 18px;
            text-align: center;
            transition: var(--transition);
        }
        .stat-card:hover {
            background: var(--secondary-hover);
            border-color: rgba(139,92,246,0.25);
        }
        .stat-icon  { font-size: 1.5rem; margin-bottom: 6px; line-height: 1; }
        .stat-value { font-size: 1.2rem; font-weight: 800; color: var(--text-primary); }
        .stat-label { font-size: 0.76rem; color: var(--text-muted); margin-top: 3px; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <div class="page" style="max-width:520px;">
        <%
            Customer customer = (Customer) session.getAttribute("customer");
            if (customer == null) {
        %>
            <div class="card">
                <div class="message message-error">⚠️ Please login to view your wallet.</div>
                <div class="stack">
                    <a href="Login.jsp" class="btn btn-primary btn-block">Login</a>
                    <a href="home" class="btn btn-secondary btn-block">← Home</a>
                </div>
            </div>
        <% } else { %>
            <div class="card">
                <h1>💳 My Wallet</h1>
                <p class="subtitle">Your secure OLX balance.</p>

                <div class="wallet-hero">
                    <div class="wallet-label">Available Balance</div>
                    <div class="wallet-amount"><%= CurrencyFormatter.format(customer.getWallet()) %></div>
                    <div class="wallet-note">Welcome back, <%= customer.getName() %> 👋</div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">🛒</div>
                        <div class="stat-value"><%= customer.getProducts() != null ? customer.getProducts().size() : 0 %></div>
                        <div class="stat-label">Total Products</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">🎂</div>
                        <div class="stat-value"><%= customer.getAge() %></div>
                        <div class="stat-label">Age</div>
                    </div>
                </div>

                <div class="row">
                    <a href="AddMoney.jsp" class="btn btn-success" style="flex:1;" id="addMoneyBtn">+ Add Money</a>
                    <a href="displayproducts" class="btn btn-primary" style="flex:1;" id="browseBtn">🛒 Browse</a>
                    <a href="home" class="btn btn-secondary" style="flex:1;" id="homeBtn">← Home</a>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>
