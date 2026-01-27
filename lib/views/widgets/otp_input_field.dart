import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

class OtpInputField extends StatelessWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OtpInputFieldStateful(
      length: length,
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }
}

class _OtpInputFieldStateful extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const _OtpInputFieldStateful({
    required this.length,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<_OtpInputFieldStateful> createState() => _OtpInputFieldStatefulState();
}

class _OtpInputFieldStatefulState extends State<_OtpInputFieldStateful> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _otp = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _otp.add('');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    // Update the OTP array
    if (value.length > 1) {
      // Handle paste - fill multiple fields
      for (int i = 0; i < widget.length && i < value.length; i++) {
        if (i < _controllers.length && i < _otp.length) {
          _controllers[i].text = value[i];
          _otp[i] = value[i];
        }
      }
      // Move focus to last field
      if (widget.length - 1 < _focusNodes.length) {
        _focusNodes[widget.length - 1].requestFocus();
      }
    } else {
      // Handle single character input
      // TextField controller is automatically updated, just update our OTP array
      if (index < _otp.length) {
        _otp[index] = value;
      }
    }

    // Get current OTP string
    final otpString = _otp.join('');
    
    // Notify listeners
    widget.onChanged?.call(otpString);

    // Handle focus movement and completion
    if (otpString.length == widget.length) {
      // All fields filled
      widget.onCompleted?.call(otpString);
    } else if (value.isNotEmpty && index < widget.length - 1) {
      // Move to next field
      if (index + 1 < _focusNodes.length) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Handle backspace - move to previous field and clear it
      if (index - 1 < _focusNodes.length && index - 1 < _otp.length) {
        _otp[index - 1] = '';
        if (index - 1 < _controllers.length) {
          _controllers[index - 1].text = '';
        }
        _focusNodes[index - 1].requestFocus();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width and spacing
        final availableWidth = constraints.maxWidth.isInfinite 
            ? MediaQuery.of(context).size.width - 48 // Account for padding
            : constraints.maxWidth;
        final spacing = 4.0; // Reduced spacing to prevent overflow
        final totalSpacing = spacing * (widget.length - 1) * 2; // margin on both sides
        final maxFieldWidth = 50.0;
        final calculatedWidth = (availableWidth - totalSpacing) / widget.length;
        // Use calculated width but cap at max, and ensure it's at least 35 to be usable
        final actualFieldWidth = calculatedWidth > maxFieldWidth 
            ? maxFieldWidth 
            : (calculatedWidth < 35.0 ? 35.0 : calculatedWidth);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.length,
            (index) => Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxFieldWidth,
                  minWidth: 35.0,
                ),
                width: actualFieldWidth,
                height: 50,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : spacing,
                  right: index == widget.length - 1 ? 0 : spacing,
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: false,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (value) => _onChanged(index, value),
                  onTap: () {
                    _controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    );
                  },
                  onSubmitted: (_) {
                    if (index < widget.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
