// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DialogBox extends StatefulWidget {
  final controllerCont;
  final controllerSeal;
  final controllerDemhang;
  final controllerBaoVe;
  final controllerContLoi;
  final controllerDate;

  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controllerCont,
    required this.controllerSeal, 
    required this.controllerDemhang,
    required this.controllerBaoVe,
    required this.controllerContLoi,
    required this.controllerDate,
    required this.onSave, 
    required this.onCancel}
  );

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {

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