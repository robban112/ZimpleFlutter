import 'package:flutter/material.dart';
import 'package:zimple/model/cost.dart';
import 'package:zimple/utils/constants.dart';

class TimereportCostController {
  List<Cost<String, int>> Function() getCosts;
}

class TimereportCostComponent extends StatefulWidget {
  TimereportCostController timereportCostController;
  TimereportCostComponent({this.timereportCostController});
  @override
  TimereportCostComponentState createState() => TimereportCostComponentState();
}

class TimereportCostComponentState extends State<TimereportCostComponent> {
  List<Cost<String, int>> costs = [];
  final _costListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    widget.timereportCostController.getCosts = _getCosts;
  }

  List<Cost<String, int>> _getCosts() {
    return costs;
  }

  Container _buildCost(Cost<String, int> cost) {
    return Container(
      height: 40,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          width: 1,
          color: shadedGrey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              enabledBorder: InputBorder.none, border: InputBorder.none),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          controller: TextEditingController(text: cost.b.toString()),
          onChanged: (text) {
            try {
              var intCost = int.parse(text) ?? 0;
              cost.b = intCost;
            } on FormatException {
              cost.b = 0;
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
          cost.a = text;
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
          focusColor: Colors.red,
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(12.0),
          //   ),
          // ),
        ),
      ),
    );
  }

  Container _buildCostDetails(Cost cost, Function onTapDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 150,
            child: _buildCostDescription(cost),
          ),
          Row(
            children: [
              _buildCost(cost),
              SizedBox(width: 5.0),
              Text("kr"),
              SizedBox(width: 5.0),
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
    Cost<String, int> cost = costs[index];
    return _buildCostDetails(cost, () {
      setState(() {
        costs.removeAt(index);
        _costListKey.currentState.removeItem(index, (context, animation) {
          return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: _buildCostDetails(cost, () {}));
        });
      });
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
            setState(() {
              costs.add(Cost("", 0));
              _costListKey.currentState.insertItem(costs.length - 1);
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )
      ],
    );
  }
}
