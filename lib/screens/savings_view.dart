import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';

class SavingsView extends StatefulWidget {
  final List<SavingsTransaction> transactions;
  final List<CharityOrganization> charities;
  final CustomerProfile profile;
  final Function(int amountLKR, BankAccount bankAccount) onWithdrawToBank;
  final Function(int amountLKR, CharityOrganization charity) onDonateToCharity;
  final VoidCallback onBackHome;

  const SavingsView({
    super.key,
    required this.transactions,
    required this.charities,
    required this.profile,
    required this.onWithdrawToBank,
    required this.onDonateToCharity,
    required this.onBackHome,
  });

  @override
  State<SavingsView> createState() => _SavingsViewState();
}

class _SavingsViewState extends State<SavingsView> {
  String _activeSubTab = 'ledger'; // 'ledger' | 'withdraw' | 'donate'

  // Withdraw state
  late String _selectedBankId;
  final TextEditingController _withdrawAmountController =
      TextEditingController(text: '1000');
  String? _withdrawError;
  Map<String, dynamic>? _withdrawalReceipt;

  // Donate state
  late CharityOrganization _selectedCharity;
  final TextEditingController _donationAmountController =
      TextEditingController(text: '500');
  String? _donationError;
  Map<String, dynamic>? _donationReceipt;

  // Simulator
  int _simulatorSampleLKR = 1000;

  @override
  void initState() {
    super.initState();
    _selectedBankId = widget.profile.bankAccounts.isNotEmpty
        ? widget.profile.bankAccounts.first.id
        : 'bank-combank';
    _selectedCharity = widget.charities.first;
  }

  @override
  void dispose() {
    _withdrawAmountController.dispose();
    _donationAmountController.dispose();
    super.dispose();
  }

  void _handleBankWithdrawal() {
    final amount = int.tryParse(_withdrawAmountController.text.trim()) ?? 0;
    const currentYearMonth = '2026-10';
    final summary = summarizeSavingsLedger(widget.transactions, currentYearMonth);

    final validation = validateMonthlyWithdrawal(
      amount,
      summary.totalBalanceLKR,
      widget.profile.lastWithdrawalMonth,
      currentYearMonth,
    );

    if (!validation.valid) {
      setState(() {
        _withdrawError = validation.error;
      });
      return;
    }

    final bank = widget.profile.bankAccounts.firstWhere(
      (b) => b.id == _selectedBankId,
      orElse: () => widget.profile.bankAccounts.first,
    );

    widget.onWithdrawToBank(amount, bank);

    setState(() {
      _withdrawError = null;
      _withdrawalReceipt = {
        'refId': 'WDR-GD-${100 + (amount % 800)}',
        'amountLKR': amount,
        'bank': bank,
        'timestamp': 'Just now',
      };
    });
  }

  void _handleCharityDonation() {
    final amount = int.tryParse(_donationAmountController.text.trim()) ?? 0;
    const currentYearMonth = '2026-10';
    final summary = summarizeSavingsLedger(widget.transactions, currentYearMonth);

    if (amount < 50) {
      setState(() {
        _donationError = 'Minimum donation amount is LKR 50.';
      });
      return;
    }

    if (amount > summary.totalBalanceLKR) {
      setState(() {
        _donationError =
            'Donation amount exceeds your available savings balance of LKR ${formatLKR(summary.totalBalanceLKR)}.';
      });
      return;
    }

    widget.onDonateToCharity(amount, _selectedCharity);

    setState(() {
      _donationError = null;
      _donationReceipt = {
        'refId': 'DON-GD-${100 + (amount % 800)}',
        'amountLKR': amount,
        'charity': _selectedCharity,
        'timestamp': 'Just now',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    const currentYearMonth = '2026-10';
    final summary = summarizeSavingsLedger(widget.transactions, currentYearMonth);
    final simResult = calculateSavingsAllocation(_simulatorSampleLKR);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ORANGE & NAVY FROSTED HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F243C), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: widget.onBackHome,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.arrow_back,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Home',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '10% Savings Wallet',
                                style: TextStyle(
                                  color: Color(0xFFFDBA74),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Automated Customer Rewards',
                                style: TextStyle(
                                  color: Color(0xFFFED7AA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Balance Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildHeaderStatBox(
                              label: 'Available Balance',
                              value: 'LKR ${formatLKR(summary.totalBalanceLKR)}',
                              sub: '+LKR ${formatLKR(summary.currentMonthSavedLKR)} this month',
                              valueColor: const Color(0xFFFDE047),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHeaderStatBox(
                              label: 'Total Giving',
                              value: 'LKR ${formatLKR(summary.totalDonatedLKR)}',
                              sub: '5 Verified Charities',
                              valueColor: const Color(0xFF86EFAC),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Sub-tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSubTabBtn(
                                id: 'ledger',
                                label: 'Savings Ledger',
                                icon: Icons.receipt_long,
                              ),
                            ),
                            Expanded(
                              child: _buildSubTabBtn(
                                id: 'withdraw',
                                label: 'Bank (1x/mo)',
                                icon: Icons.account_balance,
                              ),
                            ),
                            Expanded(
                              child: _buildSubTabBtn(
                                id: 'donate',
                                label: 'Donate',
                                icon: Icons.favorite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MAIN CONTENT
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_activeSubTab == 'ledger') _buildLedgerTab(simResult),
                    if (_activeSubTab == 'withdraw') _buildWithdrawTab(summary),
                    if (_activeSubTab == 'donate') _buildDonateTab(summary),
                  ],
                ),
              ),
            ],
          ),
        ),

        // RECEIPT MODALS
        if (_withdrawalReceipt != null) _buildWithdrawalReceiptModal(),
        if (_donationReceipt != null) _buildDonationReceiptModal(),
      ],
    );
  }

  Widget _buildHeaderStatBox({
    required String label,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(color: Colors.white60, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildSubTabBtn({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSel = _activeSubTab == id;
    return InkWell(
      onTap: () {
        setState(() {
          _activeSubTab = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.savingsOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerTab(SavingsAllocationResult simResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 10% Savings Simulator Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate_outlined,
                      size: 16, color: AppTheme.savingsOrange),
                  SizedBox(width: 6),
                  Text(
                    '10% Savings Rule Calculator',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate900),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '10% of every eligible order amount is credited instantly to your savings wallet.',
                style: TextStyle(fontSize: 11, color: AppTheme.slate500),
              ),
              const SizedBox(height: 10),
              Row(
                children: [500, 1000, 2000, 3500].map((amt) {
                  final isSel = _simulatorSampleLKR == amt;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _simulatorSampleLKR = amt;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFFFF7ED)
                              : AppTheme.slate100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel
                                ? AppTheme.savingsOrange
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'LKR $amt',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSel
                                ? AppTheme.savingsOrange
                                : AppTheme.slate700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Eligible Spend',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.slate500)),
                        Text('LKR ${formatLKR(simResult.eligibleAmountLKR)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('10% Savings',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.savingsOrange)),
                        Text('+LKR ${formatLKR(simResult.savingsCreditLKR)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.savingsOrange)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Settlement',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.slate500)),
                        Text(
                            'LKR ${formatLKR(simResult.remainingSettlementLKR)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Transactions Ledger (${widget.transactions.length})',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.slate900),
        ),
        const SizedBox(height: 10),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.transactions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final tx = widget.transactions[idx];
            final isCredit = tx.amountLKR > 0;

            IconData icon = Icons.savings;
            Color iconColor = AppTheme.savingsOrange;
            if (tx.type == 'credit_order') {
              icon = Icons.restaurant;
              iconColor = AppTheme.foodGreen;
            } else if (tx.type == 'credit_ride') {
              icon = Icons.directions_car;
              iconColor = AppTheme.primaryBlue;
            } else if (tx.type == 'withdrawal_bank') {
              icon = Icons.account_balance;
              iconColor = Colors.purple;
            } else if (tx.type == 'donation_charity') {
              icon = Icons.favorite;
              iconColor = Colors.red;
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate900,
                          ),
                        ),
                        Text(
                          '${tx.date} · ${tx.referenceId}',
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.slate500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isCredit ? '+' : ''}LKR ${formatLKR(tx.amountLKR)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isCredit ? AppTheme.foodGreen : Colors.red[700],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWithdrawTab(SavingsLedgerSummary summary) {
    const currentYearMonth = '2026-10';
    final hasWithdrawn =
        widget.profile.lastWithdrawalMonth == currentYearMonth;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Transfer Savings to Local Bank Account',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rule: Once per calendar month. Minimum LKR 200.',
            style: TextStyle(fontSize: 11, color: AppTheme.slate500),
          ),
          const SizedBox(height: 12),

          // Bank selector
          Column(
            children: widget.profile.bankAccounts.map((bank) {
              final isSel = _selectedBankId == bank.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedBankId = bank.id;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel
                          ? AppTheme.primaryBlue
                          : AppTheme.slate200,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance,
                          size: 20, color: AppTheme.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bank.bankName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${bank.branchName} · ${bank.accountNumberMasked}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.slate500)),
                          ],
                        ),
                      ),
                      if (bank.isVerified)
                        const Icon(Icons.check_circle,
                            size: 16, color: AppTheme.foodGreen),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Amount input
          TextField(
            controller: _withdrawAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Withdrawal Amount (LKR)',
              labelStyle: const TextStyle(fontSize: 11),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (_withdrawError != null) ...[
            const SizedBox(height: 8),
            Text(
              _withdrawError!,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: hasWithdrawn ? null : _handleBankWithdrawal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              hasWithdrawn
                  ? 'Monthly Withdrawal Limit Reached'
                  : 'Transfer to Bank Account',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateTab(SavingsLedgerSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Verified Sri Lankan Charities',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.slate900),
        ),
        const SizedBox(height: 4),
        const Text(
          '100% of your donated savings goes directly to the organization with zero platform deduction.',
          style: TextStyle(fontSize: 11, color: AppTheme.slate500),
        ),
        const SizedBox(height: 10),

        // Charities list
        Column(
          children: widget.charities.map((c) {
            final isSel = _selectedCharity.id == c.id;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCharity = c;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFFFF1F2) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? Colors.red : AppTheme.slate200,
                    width: isSel ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate900,
                            ),
                          ),
                        ),
                        if (c.verifiedBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                  color: Color(0xFF166534),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.slate600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Impact: ${c.impactMetric} · Raised: LKR ${formatLKR(c.totalRaisedOnPlatformLKR)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Donation input
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _donationAmountController,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Donation Amount (LKR)',
                  labelStyle: const TextStyle(fontSize: 11),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_donationError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _donationError!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _handleCharityDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Donate to ${_selectedCharity.name.split(' ')[0]}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalReceiptModal() {
    final w = _withdrawalReceipt!;
    final bank = w['bank'] as BankAccount;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 22, color: AppTheme.foodGreen),
                    SizedBox(width: 8),
                    Text(
                      'Transfer Initiated',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _withdrawalReceipt = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Ref: ${w['refId']}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
            Text('Amount: LKR ${formatLKR(w['amountLKR'] as int)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900)),
            Text('Bank: ${bank.bankName} (${bank.accountNumberMasked})',
                style: const TextStyle(fontSize: 11, color: AppTheme.slate700)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _withdrawalReceipt = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDonationReceiptModal() {
    final d = _donationReceipt!;
    final c = d['charity'] as CharityOrganization;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite, size: 22, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Donation Certificate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _donationReceipt = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Receipt: ${d['refId']}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
            Text('Amount: LKR ${formatLKR(d['amountLKR'] as int)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900)),
            Text('Charity: ${c.name} (${c.registrationNo})',
                style: const TextStyle(fontSize: 11, color: AppTheme.slate700)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _donationReceipt = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
