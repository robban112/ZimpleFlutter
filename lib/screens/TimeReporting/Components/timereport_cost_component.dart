import 'package:flutter/material.dart';
import 'package:zimple/model/cost.dart';
import 'package:zimple/widgets/rectangular_button.dart';

class TimereportCostComponent extends StatelessWidget {
  final List<Cost> costs;
  final Function(Cost) didAddCost;
  final Function(Cost) didRemoveCost;
  TimereportCostComponent(
      {Key? key,
      required this.costs,
      required this.didAddCost,
      required this.didRemoveCost})
      : super(key: key);

  Container _buildCostDetails(BuildContext context, Cost cost) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: width / 3, child: Text(cost.description)),
          SizedBox(
            width: width / 6,
            child: Text(cost.amount.toString()),
          ),
          Row(
            children: [
              Text(
                '${cost.cost.toString()} kr',
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 12.0),
              //Text("kr"),
              SizedBox(width: 2.0),
              Container(
                height: 25,
                width: 25,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => didRemoveCost(cost),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Container _buildCostRow(BuildContext context, int index) {
    Cost cost = costs[index];
    return _buildCostDetails(context, cost);
  }

  void didTapAddCost(BuildContext context) {
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
              didAddCost(cost);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print("Building Timereport Cost Component");
    const padding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(costs.length, (index) {
              return _buildCostRow(context, index);
            })),
        Container(
          child: Center(
            child: MaterialButton(
              color: Colors.grey.shade200,
              elevation: 0.0,
              child: Text("Lägg till utgift",
                  style: TextStyle(color: Colors.black)),
              onPressed: () {
                didTapAddCost(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
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
                                  Cost cost = Cost(
                                      description: descriptionController.text,
                                      cost: int.parse(costController.text),
                                      amount: int.parse(amountController.text));

                                  widget.didAddCost(cost);
                                  //Navigator.pop(context);
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
