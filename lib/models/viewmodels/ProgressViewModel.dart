import 'package:mega_civ_rules/models/data/civilizationadvance.dart';

class ProgressViewModel {
  ProgressViewModel();

  List<CivilizationAdvance> advances = List();
  List<CivilizationAdvance> filteredAdvances = List();
  List<String> acquired = List();
  Map<String, CivilizationAdvance> allAdvancesMap = Map();

  Map<CivilizationAdvanceGroup, bool> filter = {
    CivilizationAdvanceGroup.science: true,
    CivilizationAdvanceGroup.crafts: true,
    CivilizationAdvanceGroup.civic: true,
    CivilizationAdvanceGroup.arts: true,
    CivilizationAdvanceGroup.religion: true
  };

  bool filterByAcquiered = true;
  bool filterByNotAcquiered = true;
  bool filterCostAscending = true;
  double _costFilter = 50.0;

  int getReducedCost(CivilizationAdvance advance) {
    if (acquired.length > 0) {
      int reducedSum = 0;
      acquired.forEach((id) {
        var acquiredAdvance = allAdvancesMap[id];
        if (acquiredAdvance != null) {
          var reduced = acquiredAdvance.reduceCosts.firstWhere((r) {
            return r.id == advance.id;
          }, orElse: () => null);
          if (reduced != null) {
            reducedSum += reduced.reduced;
          }
          acquiredAdvance.colorCredits.forEach((colorCredit) {
            if (advance.groups.contains(colorCredit.group)) {
              reducedSum += colorCredit.value;
            }
          });
        }
      });
      int ret = (advance.cost - reducedSum);
      return ret < 0 ? 0 : ret;
    }
    return advance.cost;
  }

  bool isAcquiered(CivilizationAdvance a) {
    return this.acquired.contains(a.id);
  }

  List<CivilizationAdvance> getAdvancesToRender() {
    return filteredAdvances;
  }

  List<String> getAcquired() {
    return this.acquired;
  }

  int _advancesSort(CivilizationAdvance a, CivilizationAdvance b) {
    int sort = a.cost - b.cost;
    if (sort < 0) return -1;
    if (sort > 0) return 1;
    return sort;
  }

  Map<String, CivilizationAdvance> getAllAdvancesMap() {
    return this.allAdvancesMap;
  }

  void _sort() {
    filteredAdvances.sort(_advancesSort);
  }

  void setAdvances(List<CivilizationAdvance> advances) {
    this.advances = advances;
    this.filteredAdvances = advances;
    allAdvancesMap = Map.fromIterable(advances,
        key: (item) => item.id, value: (item) => item);
    _sort();
  }

  void setFilterCostAscneding(bool val) {
    filterCostAscending = val;
    filterAdvances();
  }

  bool getFilterCostAscending() {
    return filterCostAscending;
  }

  void setGroupFilter(CivilizationAdvanceGroup group, bool value) {
    filter[group] = value;
    filterAdvances();
  }

  void setAcquired(List<String> acquired) {
    this.acquired = acquired;
    filterAdvances();
  }

  bool getFilterByAcquiered() {
    return this.filterByAcquiered;
  }

  bool getFilterByNotAquiered() {
    return this.filterByNotAcquiered;
  }

  Map<CivilizationAdvanceGroup, bool> getGroupFilter() {
    return this.filter;
  }

  String groupToString(CivilizationAdvanceGroup group) {
    return group.toString().replaceAll("CivilizationAdvanceGroup.", "");
  }

  bool getGroupFilterValue(CivilizationAdvanceGroup group) {
    return this.filter[group];
  }

  List<String> addRemoveAcquiered(String id, bool add) {
    if (add) {
      this.acquired.add(id);
    } else {
      this.acquired.remove(id);
    }
    return this.acquired;
  }

  void setCostFilter(double value) {
    _costFilter = value;
    filterAdvances();
  }

  double getCostFilterValue() {
    return _costFilter;
  }

  String getVictoryPoints() {
    if (acquired.length > 0 && advances.length > 0) {
      return this
          .acquired
          .map((a) {
            var found = this
                .advances
                .firstWhere((ad) => ad.id == a, orElse: () => null);
            return found != null ? found.victoryPoints : 0;
          })
          .reduce((value, element) => value + element)
          .toString();
    }
    return "0";
  }

  void setFilterByAcquiered(bool val) {
    this.filterByAcquiered = val;
    filterAdvances();
  }

  void setFilterByNotAcquiered(bool val) {
    this.filterByNotAcquiered = val;
    filterAdvances();
  }

  void filterAdvances() {
    var activeFilter = this.filter.keys.where((key) => filter[key]);
    var filterByGroup = (groups) {
      for (var g in groups) {
        if (activeFilter.contains(g)) {
          return true;
        }
      }
      return false;
    };
    var filterByAcquiered = (id) {
      return this.acquired.contains(id);
    };
    var filterByNotAquieredFunction = (id) {
      return !this.acquired.contains(id);
    };

    this.filteredAdvances = this.advances.where((a) {
      // Filter by group
      var byGroup = filterByGroup(a.groups);
      if (byGroup &&
          (filterCostAscending
              ? a.cost >= _costFilter
              : a.cost <= _costFilter)) {
        bool shouldFilter = true;
        if (this.filterByAcquiered) {
          shouldFilter = filterByAcquiered(a.id);
        } else {
          shouldFilter = false;
        }
        if (this.filterByNotAcquiered) {
          shouldFilter = shouldFilter || filterByNotAquieredFunction(a.id);
        }
        return shouldFilter;
      }
      return false;
    }).toList();
  }
}
