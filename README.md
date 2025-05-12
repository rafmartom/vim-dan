# vim-dan

A vimhelp way for offline viewing of any documentation available on the Web


## Example

![vim-dan-demo svg](./assets/vim-dan-demo.svg)

Note: Links stand out more than in the previous svg rendering. See the Asciinema below

[vim-dan-demo asciinema](https://asciinema.org/a/eTA3diK9MmcbKqyJHy6HWNOkF)

## Explanation 

`.dan` Documentations, have an interactive TOC a the Top that lets you navigate to each article (pressing `Ctrl + ]` ), may this be a **language feature** , a **method** , a **class** , a **tutorial page** etc... . They correspond to a different page on the Source Website.
You can see that there is a link there because is highlighted, the TOC is displayed hierarchicaly.

Within the topics you may find other highlighted words, that may address to other topics or sections of each topic.Also access them pressing `Ctr + ]` .

Note that when there is only one link in a line, just placing the cursor anywhere within the line pressing `Ctrl + ]` will take you to the target of that link, instead if there are many links, you need to place the cursor on top of the keyword then trigger the `Ctrl + ]`.

You can highlight lines you consider important by pressing `Ctrl + p`, meaning this will append a `(X)` at the end of the line, and by pressing `<F5>` vim will open a `Location List` with all those lines in a document, in this Location List you can just see all the lines you have highlighted, and placing the cursor on top of any of the lines you will be able to by pressing `<Enter>` to go to that specific line within the Document. 



## Installing plugin

Use any of your vim Plugin manager, in my case I use `vundle` so I add the following directive to my `.vimrc`

```
Plugin 'rafmartom/vim-dan'
```


## Installing documentations

In order for using `vim-dan` files, you need to get the `${DOCU}.dan` file alongside the tag file `.tags${DOCU}`.


Most of the documentations are available on [vim-dan-generator ready-docus](https://github.com/rafmartom/vim-dan-generator/tree/main/ready-docus)
The `${DOCU}` name should be a few words descriptive name of the language, framework, technology , organization, craft, ... its documented alongside its source (if there are to be many)
For instance look for `mdn-css` would correspond to the **Mozilla MDN Web Docs** for **CSS** coming from `https://developer.mozilla.org/en-US/docs/Web/CSS` , you can also find `mdn-js`, `mdn-html` , etc...
You can also search for a substring of the URL you are looking for such as `repo:rafmartom/vim-dan-generator developer.mozilla` you check the filename corresponding in `/vim-dan-generator/ready-docus/mdn-css.dan`

Then you can

```
wget https://raw.githubusercontent.com/rafmartom/vim-dan-generator/main/ready-docus/mdn-css.dan
wget https://raw.githubusercontent.com/rafmartom/vim-dan-generator/main/ready-docus/.tagsmdn-css
```



## Missing an important documentation/feature?

If you feel that we have missed an important documentation or that there is some feature that would be nice to have, please post a "New Issue" in the repo, for features of vim-dan itself post it in this repo, if it is about a documentation please post it on [vim-dan-generator](https://github.com/rafmartom/vim-dan-generator)
