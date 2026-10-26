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
    private String fmtDate(java.sql.Date d) {
        if (d == null) return "";
        return new java.text.SimpleDateFormat("d MMM yyyy").format(d);
    }
%>
<html data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Listings – OLX Marketplace</title>
    <meta name="description" content="Manage your active and sold product listings on OLX.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .listings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 18px;
            margin-top: 24px;
        }

        /* Management card — extends pcard with action row */
        .mgmt-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: var(--transition);
            position: relative;
        }
        .mgmt-card:hover {
            transform: translateY(-4px);
            border-color: rgba(139,92,246,0.3);
            box-shadow: 0 14px 36px rgba(0,0,0,0.2);
        }
        [data-theme="light"] .mgmt-card:hover {
            box-shadow: 0 8px 24px rgba(15,23,42,0.1);
        }
        .mgmt-card-actions {
            padding: 12px 14px;
            border-top: 1px solid var(--divider);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 7px;
        }
        .mgmt-card-actions .btn { padding: 8px 6px; font-size: 0.8rem; border-radius: 8px; }
        .actions-full { grid-column: 1 / -1; display: flex; gap: 7px; }
        .actions-full .btn { flex: 1; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <%
        List<Product> listings = (List<Product>) request.getAttribute("listings");
    %>
    <div class="page">
        <div class="card">
            <h1>🏷️ My Listings</h1>
            <p class="subtitle">Manage the products you have listed for sale.</p>

            <% if (request.getAttribute("msg") != null) {
                String msgVal = request.getAttribute("msg").toString();
                boolean isErr = msgVal.toLowerCase().contains("cannot") || msgVal.toLowerCase().contains("unauthorized") || msgVal.toLowerCase().contains("error");
            %>
                <div class="message <%= isErr ? "message-error" : "message-success" %>">${msg}</div>
            <% } %>

            <% if (listings == null || listings.isEmpty()) { %>
                <%-- EMPTY STATE --%>
                <div class="empty-state">
                    <div class="empty-state-icon">📦</div>
                    <div class="empty-state-title">No Listings Yet</div>
                    <div class="empty-state-desc">You haven't listed any products for sale. Start selling and reach thousands of buyers!</div>
                    <a href="AddProduct.jsp" class="btn btn-primary" style="margin-top:8px;" id="addFirstProductBtn">+ Sell Your First Product</a>
                </div>
            <% } else { %>
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px; flex-wrap:wrap; gap:10px;">
                    <span style="font-size:0.85rem; color:var(--text-secondary);"><%= listings.size() %> listing<%= listings.size() != 1 ? "s" : "" %></span>
                    <a href="AddProduct.jsp" class="btn btn-sm btn-primary" id="addProductBtn">+ Add New Product</a>
                </div>
                <div class="listings-grid">
                    <% for (Product p : listings) {
                        String dName = cleanName(p.getName());
                        String dDate = fmtDate(p.getCreatedDate());
                        boolean isSold = Product.STATUS_SOLD.equals(p.getStatus());
                    %>
                    <div class="mgmt-card" id="listing-<%= p.getId() %>">
                        <%-- Status badge --%>
                        <div class="pcard-img-wrap" style="padding-top:62%;">
                            <% if (isSold) { %>
                                <span class="pcard-status pcard-status-sold">SOLD</span>
                            <% } else { %>
                                <span class="pcard-status pcard-status-available">AVAILABLE</span>
                            <% } %>
                            <% if (p.getImage() != null && p.getImage().length > 0) { %>
                                <img class="pcard-img" src="product-image?id=<%= p.getId() %>"
                                     alt="<%= dName %>" loading="lazy">
                            <% } else { %>
                                <div class="pcard-no-img">
                                    <span class="no-img-icon">📷</span>
                                    <span class="no-img-text">No Image</span>
                                </div>
                            <% } %>
                        </div>

                        <%-- Body --%>
                        <div class="pcard-body">
                            <div class="pcard-name" title="<%= dName %>"><%= dName %></div>
                            <div class="pcard-price"><%= CurrencyFormatter.format(p.getPrice()) %></div>
                            <div class="pcard-badges">
                                <% if (p.getCategory() != null && !p.getCategory().isEmpty()) { %>
                                    <span class="pbadge pbadge-cat"><%= p.getCategory() %></span>
                                <% } %>
                                <% if (p.getProductCondition() != null && !p.getProductCondition().isEmpty()) { %>
                                    <span class="pbadge pbadge-cond"><%= p.getProductCondition() %></span>
                                <% } %>
                            </div>
                            <% if (p.getLocation() != null && !p.getLocation().isEmpty()) { %>
                                <div class="pcard-meta">📍 <%= p.getLocation() %></div>
                            <% } %>
                            <% if (!dDate.isEmpty()) { %>
                                <div class="pcard-meta" style="color:var(--text-muted); font-size:0.74rem;">📅 Listed <%= dDate %></div>
                            <% } %>
                        </div>

                        <%-- Action Buttons --%>
                        <div class="mgmt-card-actions">
                            <a href="productdetails?id=<%= p.getId() %>" class="btn btn-secondary">View</a>

                            <% if (!isSold) { %>
                                <a href="editproduct?id=<%= p.getId() %>" class="btn btn-primary">Edit ✏️</a>
                                <div class="actions-full">
                                    <a href="markassold?id=<%= p.getId() %>" class="btn btn-success"
                                       onclick="return confirm('Mark this item as SOLD? This cannot be undone.')">Mark Sold ✓</a>
                                    <a href="deleteproduct?id=<%= p.getId() %>" class="btn btn-danger"
                                       onclick="return confirm('Delete this listing permanently?')">Delete</a>
                                </div>
                            <% } else { %>
                                <button class="btn btn-secondary" disabled style="opacity:0.4; cursor:not-allowed;">Sold</button>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>

            <div style="margin-top:28px;">
                <a href="home" class="btn btn-secondary">← Back to Home</a>
            </div>
        </div>
    </div>
</body>
</html>
