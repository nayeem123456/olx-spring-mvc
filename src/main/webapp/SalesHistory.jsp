<%@page import="mvc_olx.dto.Product"%>
<%@page import="java.util.List"%>
<%@page import="mvc_olx.helper.CurrencyFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<%!
    private String cleanName(String name) {
        if (name == null || name.isEmpty()) return "Unnamed Product";
        return name.replaceAll("\\s*\\(\\d+\\)\\s*$", "").trim();
    }
%>
<html data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Sales History – OLX Marketplace</title>
    <meta name="description" content="Track all your completed sales and earnings on OLX.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .history-table td { vertical-align: middle; }

        .small-img {
            width: 72px; height: 52px;
            object-fit: cover;
            border-radius: 10px;
            border: 1px solid var(--card-border);
            display: block;
        }
        .img-placeholder {
            width: 72px; height: 52px;
            background: var(--placeholder-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            font-size: 1.2rem;
            color: var(--text-muted);
            border: 1px solid var(--card-border);
        }
        .sale-price {
            font-weight: 800;
            color: var(--success);
            white-space: nowrap;
        }
        [data-theme="light"] .sale-price { color: #059669; }

        .product-link {
            font-weight: 700;
            color: var(--primary-hover);
            text-decoration: none;
            transition: var(--transition);
        }
        .product-link:hover { color: var(--primary); text-decoration: underline; }
        [data-theme="light"] .product-link { color: #7C3AED; }

        .buyer-name-cell { font-weight: 600; color: var(--text-primary); }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <%
        List<Product> sales = (List<Product>) request.getAttribute("sales");
        List<String> buyerNames        = (List<String>) request.getAttribute("buyerNames");
        List<String> buyerCustomerIds  = (List<String>) request.getAttribute("buyerCustomerIds");
    %>
    <div class="page">
        <div class="card">
            <h1>🤝 My Sales History</h1>
            <p class="subtitle">Track all items you have successfully sold on OLX.</p>

            <% if (sales == null || sales.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">📊</div>
                    <div class="empty-state-title">No Sales Yet</div>
                    <div class="empty-state-desc">You haven't sold any items yet. List your products and start earning!</div>
                    <a href="AddProduct.jsp" class="btn btn-primary" style="margin-top:8px;" id="startSellingBtn">+ Start Selling</a>
                </div>
            <% } else { %>
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px; flex-wrap:wrap; gap:10px;">
                    <span style="font-size:0.85rem; color:var(--text-secondary);"><%= sales.size() %> sale<%= sales.size() != 1 ? "s" : "" %> total</span>
                    <span class="badge badge-available">✅ All Completed</span>
                </div>

                <div class="table-wrap">
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Photo</th>
                                <th>Product</th>
                                <th>Buyer</th>
                                <th>Amount</th>
                                <th>Sold Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < sales.size(); i++) {
                                Product p = sales.get(i);
                                String buyerName = buyerNames.get(i);
                                String dName = cleanName(p.getName());
                            %>
                            <tr>
                                <td>
                                    <% if (p.getImage() != null && p.getImage().length > 0) { %>
                                        <img class="small-img" src="product-image?id=<%= p.getId() %>" alt="<%= dName %>">
                                    <% } else { %>
                                        <div class="img-placeholder" title="No Image">📷</div>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="productdetails?id=<%= p.getId() %>" class="product-link"><%= dName %></a>
                                    <% if (p.getCategory() != null && !p.getCategory().isEmpty()) { %>
                                        <div style="margin-top:4px;"><span class="pbadge pbadge-cat"><%= p.getCategory() %></span></div>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="buyer-name-cell"><%= buyerName != null ? buyerName : "N/A" %></span>
                                </td>
                                <td>
                                    <span class="sale-price"><%= CurrencyFormatter.format(p.getPrice()) %></span>
                                </td>
                                <td style="color:var(--text-secondary); font-size:0.85rem; white-space:nowrap;">
                                    <%= p.getSoldDate() != null ? p.getSoldDate() : "N/A" %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <div style="margin-top:24px;">
                <a href="mylistings" class="btn btn-secondary">← My Listings</a>
            </div>
        </div>
    </div>
</body>
</html>
