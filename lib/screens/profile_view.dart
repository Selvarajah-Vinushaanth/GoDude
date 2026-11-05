import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';

class ProfileView extends StatefulWidget {
  final CustomerProfile profile;
  final List<ActivityBooking> bookings;
  final List<SavingsTransaction> transactions;
  final ValueChanged<CustomerProfile> onUpdateProfile;
  final VoidCallback onResetDemoData;

  const ProfileView({
    super.key,
    required this.profile,
    required this.bookings,
    required this.transactions,
    required this.onUpdateProfile,
    required this.onResetDemoData,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isAddingAddress = false;
  String _newAddressLabel = 'Home';
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController =
      TextEditingController(text: 'Colombo 05');
  final TextEditingController _landmarkController = TextEditingController();

  String? _policyModalTitle;
  String? _policyModalContent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _savePersonalInfo() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      return;
    }
    widget.profile.fullName = _nameController.text.trim();
    widget.profile.phone = _phoneController.text.trim();
    widget.profile.email = _emailController.text.trim();
    widget.onUpdateProfile(widget.profile);
    setState(() {
      _isEditing = false;
    });
  }

  void _saveNewAddress() {
    final line = _addressLineController.text.trim();
    if (line.isEmpty) return;

    final newAddr = SavedAddress(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _newAddressLabel,
      addressLine: line,
      city: _cityController.text.trim(),
      landmark: _landmarkController.text.trim(),
    );

    widget.profile.savedAddresses.add(newAddr);
    widget.onUpdateProfile(widget.profile);

    setState(() {
      _isAddingAddress = false;
      _addressLineController.clear();
      _landmarkController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ledger = summarizeSavingsLedger(widget.transactions, '2026-10');
    final lifetimeSaved =
        ledger.totalBalanceLKR + ledger.totalWithdrawnLKR + ledger.totalDonatedLKR;

    final totalFoodOrders = 22 +
        widget.bookings
            .where((b) =>
                b.serviceType == 'Food Delivery' && b.status != 'Cancelled')
            .length;

    final totalRides = 28 +
        widget.bookings
            .where((b) =>
                (b.serviceType == 'Ride Booking' ||
                    b.serviceType == 'Parcel Delivery' ||
                    b.serviceType == 'Flexible Ride') &&
                b.status != 'Cancelled')
            .length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER (DARK NAVY)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: AppTheme.darkNavy,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Account ${widget.profile.accountId}',
                              style: const TextStyle(
                                color: AppTheme.skyBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.check : Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              if (_isEditing) {
                                _savePersonalInfo();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (!_isEditing) ...[
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.skyBlue, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.profile.fullName
                                    .split(' ')
                                    .map((n) => n.isNotEmpty ? n[0] : '')
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.profile.fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${widget.profile.phone} · ${widget.profile.email}',
                                    style: const TextStyle(
                                      color: Color(0xFFBAE6FD),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Member since ${widget.profile.memberSince} · ${widget.profile.rating} ★ Customer Rating',
                                    style: const TextStyle(
                                      color: AppTheme.foodYellow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Inline Editing
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(color: AppTheme.skyBlue, fontSize: 11),
                          ),
                        ),
                        TextField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            labelStyle: TextStyle(color: AppTheme.skyBlue, fontSize: 11),
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: AppTheme.skyBlue, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _savePersonalInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Profile Changes'),
                        ),
                      ],
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
                    // Verified Platform Metrics (3 boxes)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricBox(
                            label: 'Food Orders',
                            value: '$totalFoodOrders',
                            sub: 'Lifetime',
                            color: AppTheme.foodGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricBox(
                            label: 'Rides & Courier',
                            value: '$totalRides',
                            sub: 'Completed',
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricBox(
                            label: 'Total Saved',
                            value: 'LKR ${formatLKR(lifetimeSaved)}',
                            sub: '10% Auto',
                            color: AppTheme.savingsOrange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Saved Delivery Addresses
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved Delivery Addresses',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.slate900,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isAddingAddress = !_isAddingAddress;
                            });
                          },
                          child: Text(
                            _isAddingAddress ? 'Cancel' : '+ Add Address',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_isAddingAddress) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButton<String>(
                              value: _newAddressLabel,
                              isExpanded: true,
                              items: ['Home', 'Work', 'Other'].map((l) {
                                return DropdownMenuItem(value: l, child: Text(l));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _newAddressLabel = v;
                                  });
                                }
                              },
                            ),
                            TextField(
                              controller: _addressLineController,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'Address Line',
                                labelStyle: TextStyle(fontSize: 11),
                              ),
                            ),
                            TextField(
                              controller: _cityController,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'City / Area',
                                labelStyle: TextStyle(fontSize: 11),
                              ),
                            ),
                            TextField(
                              controller: _landmarkController,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'Landmark',
                                labelStyle: TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _saveNewAddress,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Address'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Column(
                      children: widget.profile.savedAddresses.map((addr) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.slate200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                addr.label == 'Home'
                                    ? Icons.home
                                    : addr.label == 'Work'
                                        ? Icons.work
                                        : Icons.location_on,
                                size: 20,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addr.label,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${addr.addressLine}, ${addr.city}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slate600),
                                    ),
                                    if (addr.landmark.isNotEmpty)
                                      Text(
                                        'Near ${addr.landmark}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.slate400),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Linked Bank Accounts
                    const Text(
                      'Linked Sri Lankan Bank Accounts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: widget.profile.bankAccounts.map((b) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.slate200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance,
                                  size: 20, color: AppTheme.primaryBlue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.bankName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${b.branchName} · ${b.accountNumberMasked}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slate600),
                                    ),
                                    Text(
                                      'Holder: ${b.accountHolder}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.slate400),
                                    ),
                                  ],
                                ),
                              ),
                              if (b.isVerified)
                                const Icon(Icons.check_circle,
                                    size: 16, color: AppTheme.foodGreen),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Policies & Compliance
                    const Text(
                      'Governance & Platform Policies',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Column(
                        children: [
                          _policyTile(
                            '10% Automatic Savings Policy',
                            'Every eligible net transaction credits 10% to customer savings ledger.',
                            'GO DUDE credits 10% of eligible food and ride amounts directly to customer wallet upon completion.',
                          ),
                          const Divider(height: 1),
                          _policyTile(
                            'Monthly Bank Withdrawal Terms',
                            'One withdrawal per calendar month, minimum LKR 200, zero processing fees.',
                            'Under Sri Lanka banking rules, customer withdrawals are processed via CEFT / SLIPS once per calendar month.',
                          ),
                          const Divider(height: 1),
                          _policyTile(
                            'Charity Organization Verification',
                            '100% of social donations disbursed to registered Sri Lankan charities.',
                            'Charities on GO DUDE are verified with registration numbers and regular platform audit reporting.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reset Demo Data Button
                    OutlinedButton.icon(
                      onPressed: widget.onResetDemoData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset Demo State & Prototype'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Policy Dialog
        if (_policyModalTitle != null)
          Container(
            color: Colors.black54,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _policyModalTitle!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _policyModalTitle = null;
                            _policyModalContent = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_policyModalContent!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.slate700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _policyModalTitle = null;
                        _policyModalContent = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Understood'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.slate500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(sub,
              style: const TextStyle(fontSize: 9, color: AppTheme.slate400)),
        ],
      ),
    );
  }

  Widget _policyTile(String title, String subtitle, String content) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 10, color: AppTheme.slate500)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {
        setState(() {
          _policyModalTitle = title;
          _policyModalContent = content;
        });
      },
    );
  }
}
