# Markdown Viewer Documentation

## Meta data

This small software is a child of the translation system created in IOI2017.

Birth: IOI 2017 Iran

Version: 6.2


## Credits

Generally: IOI 2017 Host Technical committee.

More specifically:
* Hamid Zarrabizadeh
* Ali Yadegari
* Kian Mirjalali
* Navid Saleh


## Headers and footers

Html headers and footers can be placed in `header.html` and `footer.html`, respectively.


## Naming

File "$\langle x \rangle$`.html`" reads "$\langle x \rangle$`.md`" and "$\langle x \rangle$`.json`".
For example "`Book.html`" reads "`Book.md`" and "`Book.json`".

## Properties
The JSON file should contain a simple object node like:
```
{
    "name" : "The Name",
    "other" : "The other"
}
```

For each key $k$ in the JSON (like "`name`" in example above), 
the text content of the document element whose `id` is "`prop_`$k$" becomes the value of that key.
So the text content of the element with `id="prop_name"` becomes "`The Name`".

The special key `html_title` specifies the document title.


## Defects

Currently, it only works in Firefox.
Other browsers do not allow the html scripts to access the markdown file.

