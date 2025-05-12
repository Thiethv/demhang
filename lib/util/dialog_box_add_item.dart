// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DialogBoxAddNew extends StatefulWidget {
  final controllerCont;
  final controllerSeal;
  final controllerDemhang;
  final controllerBaoVe;
  final controllerContLoi;
  final controllerDate;
  final ValueChanged<String> onRadioChanged;

  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBoxAddNew({
    super.key,
    required this.controllerCont,
    required this.controllerSeal, 
    required this.controllerDemhang,
    required this.controllerBaoVe,
    required this.controllerContLoi,
    required this.controllerDate,
    required this.onRadioChanged,
    required this.onSave, 
    required this.onCancel}
  );

  @override
  State<DialogBoxAddNew> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBoxAddNew> {
  String _selectedValue = 'Cont 40';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 480,
        // width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Nhập thông tin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            TextField(
              controller: widget.controllerCont,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Container',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                )
              ),
            ),
            TextField(
              controller: widget.controllerSeal,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Số Chì',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                )
              ),
            ),
            TextField(
              controller: widget.controllerDemhang,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'NV kho',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                )
              ),
            ),
            TextField(
              controller: widget.controllerBaoVe,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Bảo vệ',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5)
                )
              ),
            ),
            TextField(
              controller: widget.controllerContLoi,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Cont lỗi',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5)
                )
              ),
            ),
            TextField(
              controller: widget.controllerDate,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Ngày đếm hàng',
              ),
            ),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 5.0,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                        groupValue: _selectedValue,
                        value: 'Cont 40',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedValue = value!;
                            widget.onRadioChanged(_selectedValue);
                          });
                        },
                      ),
                    const Text('Cont 40')
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                        groupValue: _selectedValue,
                        value: 'Cont 20',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedValue = value!;
                            widget.onRadioChanged(_selectedValue);
                          });
                        },
                      ),
                    const Text('Cont 20')
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                        groupValue: _selectedValue,
                        value: 'Truck',
                        onChanged: (String? value) {
                          setState(() {
                            _selectedValue = value!;
                            widget.onRadioChanged(_selectedValue);
                          });
                        },
                      ),
                      const Text('Truck')
                  ],
                )
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onSave, 
                    child: const Text('LƯU')
                  ),
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onCancel, 
                    child: const Text('BỎ QUA')
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}