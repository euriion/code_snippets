import java.util.*;

public class Main {

  static Map sortByValue(Map map) {
    List list = new LinkedList(map.entrySet());
    Collections.sort(list, new Comparator() {
      public int compare(Object o1, Object o2) {
        return ((Comparable) ((Map.Entry) (o1)).getValue()).compareTo(((Map.Entry) (o2)).getValue());
      }
    });

    Map result = new LinkedHashMap();
    for (Iterator it = list.iterator(); it.hasNext();) {
        Map.Entry entry = (Map.Entry)it.next();
        result.put(entry.getKey(), entry.getValue());
    }
    return result;
  }

  public String convertMapToString(Map map) {
    List list = new LinkedList(map.entrySet());

    Collections.sort(list, Collections.reverseOrder(new Comparator() {
      public int compare(Object o1, Object o2) {
        return ((Comparable) ((Map.Entry) (o1)).getValue()).compareTo(((Map.Entry) (o2)).getValue());
      }
    }));

    StringBuilder sb = new StringBuilder();
    for (Object aList : list) {
      Map.Entry iter_item = (Map.Entry) aList;
      String field = iter_item.getKey() + ":" + iter_item.getValue();
      if (sb.length() != 0)
        sb.append(',');
      sb.append(field);
    }

    return sb.toString();
  }

  public static void main(String[] args) {
    Main main = new Main();
    HashMap hashmap = new HashMap<String, Long>();
    hashmap.put("banana", 10);
    hashmap.put("cherry", 2);
    hashmap.put("kiwi", 4);
    hashmap.put("apple", 3);

    String key = "orange";
    if (hashmap.containsKey(key)) {
      hashmap.put(key, (Integer) hashmap.get(key) + 1);
    } else {
      hashmap.put(key, 1);
    }

    key = "ora";
    if (hashmap.containsKey(key)) {
      hashmap.put(key, (Integer) hashmap.get(key) + 1);
    } else {
      hashmap.put(key, 1);
    }

    System.out.println(main.convertMapToString(hashmap));
  }
}
