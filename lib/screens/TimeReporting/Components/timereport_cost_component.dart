import 'package:flutter/material.dart';
import 'package:zimple/model/cost.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:zimple/widgets/rectangular_button.dart';

class TimereportCostController {
  late List<Cost> Function() getCosts;
}

class TimereportCostComponent extends StatefulWidget {
  final TimereportCostController timereportCostController;
  TimereportCostComponent({required this.timereportCostController});
  @override
  TimereportCostComponentState createState() => TimereportCostComponentState();
}

class TimereportCostComponentState extends State<TimereportCostComponent> {
  List<Cost> costs = [];
  final _costListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    widget.timereportCostController.getCosts = _getCosts;
  }

  List<Cost> _getCosts() {
    return costs;
  }

  Container _buildCost(Cost cost) {
    return Container(
      height: 45,
      width: 80,
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade100,
      //   borderRadius: BorderRadius.circular(24.0),
      //   border: Border.all(
      //     width: 1,
      //     color: shadedGrey,
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
            labelText: 'Kostnad',
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          controller: TextEditingController(text: cost.cost.toString()),
          onChanged: (text) {
            try {
              var intCost = int.parse(text);
              cost.cost = intCost;
            } on FormatException {
              cost.cost = 0;
            }
          },
        ),
      ),
    );
  }

  Container _buildCostDescription(Cost cost) {
    return Container(
      height: 45,
      child: TextFormField(
        onChanged: (text) {
          cost.description = text;
        },
        decoration: InputDecoration(
          //icon: Icon(Icons.attach_money),
          contentPadding: const EdgeInsets.only(
            left: 8.0,
            bottom: 2.0,
            top: 2.0,
          ),
          labelText: 'Beskrivning',
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildAmount(Cost cost) {
    var controller = TextEditingController(text: cost.amount.toString());

    return Container(
      height: 45,
      child: TextFormField(
        textAlign: TextAlign.center,
        onChanged: (text) {
          controller.selection =
              TextSelection(baseOffset: text.length, extentOffset: text.length);
          try {
            var intCost = int.parse(text);
            cost.amount = intCost;
          } on FormatException {
            cost.amount = 1;
          }
        },
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        controller: TextEditingController(text: cost.amount.toString()),
        decoration: InputDecoration(
          //icon: Icon(Icons.attach_money),
          contentPadding: const EdgeInsets.only(
            bottom: 2.0,
            top: 2.0,
          ),
          labelText: 'Antal',
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildCostDetails(Cost cost, VoidCallback onTapDelete) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width / 3,
            child: _buildCostDescription(cost),
          ),
          SizedBox(
            width: width / 6,
            child: _buildAmount(cost),
          ),
          Row(
            children: [
              _buildCost(cost),
              SizedBox(width: 2.0),
              //Text("kr"),
              SizedBox(width: 2.0),
              Container(
                height: 25,
                width: 25,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: onTapDelete,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Container _buildCostRow(int index) {
    Cost cost = costs[index];
    return _buildCostDetails(cost, () {
      setState(() {
        costs.removeAt(index);
        _costListKey.currentState?.removeItem(index, (context, animation) {
          return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: _buildCostDetails(cost, () {}));
        });
      });
    });
  }

  void didTapAddCost() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return AddCostComponent(
            didAddCost: (cost) {
              setState(() {
                costs.add(cost);
                _costListKey.currentState?.insertItem(costs.length - 1);
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10);
    return Column(
      children: [
        AnimatedList(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          key: _costListKey,
          initialItemCount: costs.length,
          itemBuilder: (context, index, animation) {
            return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: _buildCostRow(index),
            );
          },
        ),
        MaterialButton(
          color: Colors.grey.shade200,
          elevation: 0.0,
          child:
              Text("Lägg till utgift", style: TextStyle(color: Colors.black)),
          onPressed: () {
            didTapAddCost();
            // setState(() {
            //   costs.add(Cost("", 0, 1));
            //   _costListKey.currentState?.insertItem(costs.length - 1);
            // });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )
      ],
    );
  }
}

class AddCostComponent extends StatefulWidget {
  const AddCostComponent({Key? key, required this.didAddCost})
      : super(key: key);
  final Function(Cost) didAddCost;
  @override
  _AddCostComponentState createState() => _AddCostComponentState();
}

class _AddCostComponentState extends State<AddCostComponent> {
  TextEditingController costController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        builder: (context, controller) {
          return LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //SizedBox(height: 12.0),
                          Text("Lägg till utgift",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16.0),
                          TextField(
                            controller: descriptionController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                labelText: 'Utgift',
                                contentPadding: EdgeInsets.zero,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: costController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'Kostnad',
                                      contentPadding: EdgeInsets.zero,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Antal',
                                        contentPadding: EdgeInsets.zero,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always)),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          Center(
                            child: RectangularButton(
                                onTap: () {
                                  print(descriptionController.text);
                                  Cost cost = Cost(
                                      description: descriptionController.text,
                                      cost: int.parse(costController.text),
                                      amount: int.parse(amountController.text));

                                  widget.didAddCost(cost);
                                  Navigator.pop(context);
                                },
                                text: 'Lägg till utgift'),
                          )

                          // ZimpleTextField(
                          //   placeholder: 'test',
                          // )
                          // ListedView(
                          //     items: [ListedTextField(placeholder: 'test')])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
