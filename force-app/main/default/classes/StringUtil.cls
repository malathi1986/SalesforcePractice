public with sharing class StringUtil {
    public StringUtil() {

    }
    public static void stringIndex(){
    List<String> stringList = new List<String>{'Apple', 'Banana', 'Orange'};

// Traditional for loop iteration
for(Integer i = 0; i < stringList.size(); i++) {
    System.debug('Element at index ' + i + ': ' + stringList[i]);
}
    
    // Enhanced for loop (foreach) iteration
for(String fruit : stringList) {
    System.debug('Fruit: ' + fruit);
}
    }

/*merge two lists in Apex and remove duplicates*/  
public static void mergeList(){
    List<Integer> list1 = new List<Integer>{1, 2, 3, 4};
List<Integer> list2 = new List<Integer>{3, 4, 5, 6};

      /*Merge the two lists*/
List<Integer> mergedList = new List<Integer>();
mergedList.addAll(list1);
mergedList.addAll(list2);

// Remove duplicates by converting to a Set and back to a List
Set<Integer> uniqueSet = new Set<Integer>(mergedList);
List<Integer> uniqueList = new List<Integer>(uniqueSet);

// Output: [1, 2, 3, 4, 5, 6]
System.debug(uniqueList);
}
/* how to remove specific elements from a list */

public static void removeElementFromList(){
List<String> cities = new List<String>{'New York', 'San Francisco', 'Los Angeles', 'Boston'};

// Remove the element at index 2 (Los Angeles)
cities.remove(2);

// Remove 'San Francisco'
cities.remove(cities.indexOf('San Francisco'));

// Output: ['New York', 'San Francisco', 'Boston']
System.debug(cities);
}

}