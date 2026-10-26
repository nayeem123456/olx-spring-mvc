<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signup – OLX Marketplace</title>
    <meta name="description" content="Create your OLX account and start buying and selling today.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .input-icon-wrap { position: relative; }
        .input-icon-wrap .icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%); font-size: 1.1rem; pointer-events: none;
        }
        .input-icon-wrap input,
        .input-icon-wrap textarea { padding-left: 42px; }
        .field-error { font-size: 0.82rem; color: #f87171; display: none; margin-top: 2px; }
        .input-invalid { border-color: #ef4444 !important; box-shadow: 0 0 0 3px rgba(239,68,68,0.15) !important; }

        .password-strength-bar {
            height: 4px;
            border-radius: 4px;
            background: rgba(255,255,255,0.1);
            margin-top: 8px;
            overflow: hidden;
        }
        .password-strength-fill {
            height: 100%;
            width: 0%;
            border-radius: 4px;
            transition: width 0.3s ease, background 0.3s ease;
        }
        .strength-label {
            font-size: 0.8rem;
            margin-top: 4px;
            color: var(--text-secondary);
            transition: color 0.3s;
        }
        .gender-group { display: flex; gap: 16px; }
        .gender-option {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 18px;
            border: 1px solid var(--card-border);
            border-radius: 12px;
            cursor: pointer;
            flex: 1;
            justify-content: center;
            transition: var(--transition);
            color: var(--text-secondary);
            font-weight: 500;
        }
        .gender-option input { display: none; }
        .gender-option:has(input:checked) {
            border-color: var(--primary);
            background: rgba(139,92,246,0.1);
            color: var(--text-primary);
        }
        .gender-option:hover { border-color: rgba(139,92,246,0.4); }
        .signup-footer { text-align: center; margin-top: 20px; color: var(--text-secondary); font-size: 0.9rem; }
        .signup-footer a { color: var(--primary); text-decoration: none; font-weight: 600; }
        .btn-row { display: flex; gap: 12px; }
        .btn-row .btn { flex: 1; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <div class="page" style="max-width: 680px;">
        <div class="card">
            <h1>Create Account 🚀</h1>
            <p class="subtitle">Join OLX and start buying & selling in seconds.</p>

            <% if(request.getAttribute("msg") != null) { %>
                <div class="message message-error">${msg}</div>
            <% } %>

            <form action="signup" method="post" class="stack" id="signupForm" novalidate>
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <div class="input-icon-wrap">
                        <span class="icon">👤</span>
                        <input type="text" id="name" name="name" placeholder="Enter your full name" required minlength="2">
                    </div>
                    <span class="field-error" id="name-error">Name must be at least 2 characters.</span>
                </div>

                <div class="form-group">
                    <label for="mobile">Mobile Number</label>
                    <div class="input-icon-wrap">
                        <span class="icon">📱</span>
                        <input type="tel" id="mobile" name="mobile" placeholder="10-digit mobile number" pattern="[0-9]{10}" required maxlength="10">
                    </div>
                    <span class="field-error" id="mobile-error">Please enter a valid 10-digit mobile number.</span>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-icon-wrap">
                        <span class="icon">🔑</span>
                        <input type="password" id="password" name="password" placeholder="Create a strong password" required minlength="6" oninput="checkStrength(this.value)" style="padding-right: 42px;">
                        <span class="toggle-password" id="togglePassword" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; font-size: 1.1rem; user-select: none;">👁️</span>
                    </div>
                    <div class="password-strength-bar"><div class="password-strength-fill" id="strengthFill"></div></div>
                    <div class="strength-label" id="strengthLabel">Enter a password</div>
                    <span class="field-error" id="pass-error">Password must be at least 6 characters.</span>
                </div>

                <div class="form-group">
                    <label>Gender</label>
                    <div class="gender-group">
                        <label class="gender-option">
                            <input type="radio" name="gender" value="male" required> ♂ Male
                        </label>
                        <label class="gender-option">
                            <input type="radio" name="gender" value="female"> ♀ Female
                        </label>
                    </div>
                    <span class="field-error" id="gender-error">Please select a gender.</span>
                </div>

                <div class="form-group">
                    <label for="bdate">Date of Birth <small style="color:var(--text-secondary)">(Must be 18+)</small></label>
                    <div class="input-icon-wrap">
                        <span class="icon">🎂</span>
                        <input type="date" id="bdate" name="bdate" required>
                    </div>
                    <span class="field-error" id="dob-error">You must be 18 or older to register.</span>
                </div>

                <div class="form-group">
                    <label for="address">Delivery Address</label>
                    <div class="input-icon-wrap">
                        <span class="icon" style="top:20px;transform:none;">📍</span>
                        <textarea id="address" name="address" rows="3" placeholder="Enter your full address" required style="resize:vertical;"></textarea>
                    </div>
                    <span class="field-error" id="addr-error">Address is required.</span>
                </div>

                <div class="btn-row">
                    <button type="reset" class="btn btn-danger" onclick="clearErrors()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Account →</button>
                </div>
            </form>

            <div class="signup-footer">
                Already have an account? <a href="Login.jsp">Log in here</a>
            </div>
            <div style="margin-top: 14px;">
                <a href="Home.jsp" class="btn btn-secondary btn-block">← Back to Home</a>
            </div>
        </div>
    </div>

    <script>
        function checkStrength(val) {
            const fill = document.getElementById('strengthFill');
            const label = document.getElementById('strengthLabel');
            let score = 0;
            if (val.length >= 6) score++;
            if (val.length >= 10) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;

            const levels = [
                { pct: '0%', color: 'transparent', text: 'Enter a password' },
                { pct: '20%', color: '#ef4444', text: 'Very Weak' },
                { pct: '40%', color: '#f97316', text: 'Weak' },
                { pct: '60%', color: '#eab308', text: 'Fair' },
                { pct: '80%', color: '#3b82f6', text: 'Strong' },
                { pct: '100%', color: '#10b981', text: '💪 Very Strong' },
            ];
            const level = val.length === 0 ? levels[0] : levels[Math.min(score, 5)];
            fill.style.width = level.pct;
            fill.style.background = level.color;
            label.textContent = level.text;
            label.style.color = level.color === 'transparent' ? 'var(--text-secondary)' : level.color;
        }

        function showError(id, input) {
            document.getElementById(id).style.display = 'block';
            if (input) input.classList.add('input-invalid');
        }
        function clearErrors() {
            document.querySelectorAll('.field-error').forEach(e => e.style.display = 'none');
            document.querySelectorAll('.input-invalid').forEach(e => e.classList.remove('input-invalid'));
        }

        document.getElementById('signupForm').addEventListener('submit', function(e) {
            let valid = true;
            clearErrors();

            const name = document.getElementById('name');
            const mobile = document.getElementById('mobile');
            const pass = document.getElementById('password');
            const bdate = document.getElementById('bdate');
            const address = document.getElementById('address');
            const gender = document.querySelector('input[name="gender"]:checked');

            if (!name.value || name.value.trim().length < 2) { showError('name-error', name); valid = false; }
            if (!mobile.value || !/^[0-9]{10}$/.test(mobile.value)) { showError('mobile-error', mobile); valid = false; }
            if (!pass.value || pass.value.length < 6) { showError('pass-error', pass); valid = false; }
            if (!gender) { showError('gender-error', null); valid = false; }
            if (!bdate.value) {
                showError('dob-error', bdate); valid = false;
            } else {
                const dob = new Date(bdate.value);
                const age = Math.floor((Date.now() - dob.getTime()) / (365.25 * 24 * 60 * 60 * 1000));
                if (age < 18) { showError('dob-error', bdate); valid = false; }
            }
            if (!address.value || address.value.trim().length < 5) { showError('addr-error', address); valid = false; }
            if (!valid) e.preventDefault();
        });

        // Real-time clear on valid
        ['name','mobile','password','bdate','address'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.addEventListener('input', () => {
                el.classList.remove('input-invalid');
            });
        });

        const togglePassword = document.getElementById('togglePassword');
        togglePassword.addEventListener('click', function () {
            const type = pass.getAttribute('type') === 'password' ? 'text' : 'password';
            pass.setAttribute('type', type);
            togglePassword.textContent = type === 'password' ? '👁️' : '🙈';
        });
    </script>
</body>
</html>
