# Redmine Include Macro Extension

This plugin makes possible include wiki section.

Caution!) This plugin will overwrite the default include macro.

## Examples

```
{{include(Foo)}}
{{include(Foo, Bar)}} -- to include Bar section of Foo page
```

### Example: Include a section.

```
> {{include(Child, Sec2)}}
```
![Example2](doc/images/example_1.png)

### Example: Include a section with options.

```
> {{include(Child, Sec2, noheading, nosubsection)}}
```
![Example2](doc/images/example_2.png)

### Example: Include pages in table.

Both of the below codes give the same result.

```
{{include_by_table(Sec1, Sec2)
Child1
Child2
Child3
}}
```

```
|_. Wiki page |_. Sec1 |_. Sec2 |
| [[Child1]]  | {{include(Child1, Sec1, noheading, nosubsection, noraise)}} | {{include(Child1, Sec2, noheading, nosubsection, noraise)}} |
| [[Child2]]  | {{include(Child2, Sec1, noheading, nosubsection, noraise)}} | {{include(Child2, Sec2, noheading, nosubsection, noraise)}} |
| [[Child3]]  | {{include(Child3, Sec1, noheading, nosubsection, noraise)}} | {{include(Child3, Sec2, noheading, nosubsection, noraise)}} |
```
![Example2](doc/images/example_3.png)

## Installation
1. Clone or copy files into the Redmine plugins directory
  ```
  git clone https://github.com/taikii/redmine_include_macro_extension.git plugins/redmine_include_macro_extension
  ```
2. Restart Redmine

## License
This plugin is released under the MIT License.
