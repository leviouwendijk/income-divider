# Use

Just pass whatever your paycheck is:

```zsh
income 1500
```

And it will calculate savings allocations.

Either absolutely (using full principal amount of income specified) or relatively (of whatever is the remainder -- relies on order of priority for accounts).

This is default:

10% (absolute) -> savings

20% (relative) -> income_tax

10% (relative) -> charges

Example output:

```


dividing for:  1500.0
--------------------

Savings {
    principal = 1500.0
    configuration {
        order = 1
        divide = absolute
    }
    result = """
              1500.0
             10.0% x
    ----------------
               150.0
    """
}


Income_Tax {
    principal = 1500.0
    configuration {
        order = 2
        divide = relative
    }
    result = """
              1350.0
             20.0% x
    ----------------
               270.0
    """
}


Charges {
    principal = 1500.0
    configuration {
        order = 3
        divide = relative
    }
    result = """
              1080.0
             10.0% x
    ----------------
               108.0
    """
}


```
