---
title: "Hugo - Static Site Generator"
description: "How to create your own hugo website and theme."
date: 2022-07-22T13:34:17+01:00
draft: false
---

Hugo is a static site generator.
It is used to create website content using markdown instead of having to write html.
You can read more about hugo on it's [website](https://gohugo.io/).

If you are curious about how hugo was used in the implementation of this website you can also check out my [github repository](https://github.com/Fraguinha/Fraguinha.com/).

# 1. Creating the website

After you have installed hugo through your package manager of choice, you can create a new hugo site by running in your terminal:

```sh
$ hugo new site my-website
```

This will create a `my-website` directory with the following hierarchy:

```text
.
├── archetypes
│   └── default.md
├── config.toml
├── content
├── data
├── layouts
├── public
├── static
└── themes
```

The most important directories here are `content/`, which stores your website's content as markdown files, and `static/` which stores any other assets you wish to have on your website, such as images or files.

# 2. Creating a theme

Change directory into `my-website/` and run:

```sh
$ hugo new theme my-theme
```

This will create a `my-theme/` directory inside `themes/` with the following hierarchy:

```text
.
├── LICENSE
├── archetypes
│   └── default.md
├── layouts
│   ├── 404.html
│   ├── _default
│   │   ├── baseof.html
│   │   ├── list.html
│   │   └── single.html
│   ├── index.html
│   └── partials
│       ├── footer.html
│       ├── head.html
│       └── header.html
├── static
│   ├── css
│   └── js
└── theme.toml
```

The theme controls exactly how your website will look and function.
Your content will be transformed into html based on the rules you define here.

In hugo, there are two main types of pages:

- Lists
- Singles

which are created depending on the structure of your `content/` directory.
Let's imagine a directory structure like:

```text
.
├── about.md
└── post
    ├── 1st-post.md
    ├── 2nd-post.md
    └── 3rd-post.md
```

Here `about.md`, and each of the posts inside `post/` are all single pages.
`post/` itself is a list.
We can control how these pages are displayed by editing the files `single.html` and `list.html` inside `layouts/_default/`.
Let's do so.

Edit `single.html` so that the content is as follows:

```html
{{ define "main" }}
<div>{{ .Content }}</div>
{{ end }}
```

and `list.html` like so:

```html
{{ define "main" }}
<ul>
  {{ range.Pages }}
  <li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>
  {{ end }}
</ul>
{{ end }}
```

List pages will now show an unordered list with links to their single pages, and single pages will show their respective content.

Finally lets edit `index.html` inside `layout/` in order to customize our main page.

```html
<a href="/about">about</a> <a href="/post">posts</a>
```

# 3. Configuring the website

We are done with our simple theme.
Now we need to edit our `config.toml` file in order to use the theme we have just created.
Change directory back into `my-website/` and run:

```sh
$ echo "theme = 'my-theme'" >> config.toml
```

# 4. Adding content

You now have a fully functional hugo website and are ready to start posting content.
Let’s write the about page and a helloworld post.

```sh
$ hugo new about.md
$ hugo new post/helloworld.md
```

This will create a `about.md` file inside `content/` and a `helloworld.md` file inside `content/post/`.
Both files will have content similar to this:

```markdown
---
title: "About"
date: 2022-07-22T14:24:31+01:00
draft: true
---
```

Let's add some markdown to both.

Edit `about.md`:

```markdown
---
title: "About"
date: 2022-07-22T14:24:31+01:00
draft: true
---

This is the about page.
```

Edit `helloworld.md`:

```markdown
---
title: "Helloworld"
date: 2022-07-22T14:24:31+01:00
draft: true
---

# Helloworld

this is an example.
```

# 5. Live preview

We are now ready to see the results using a local server provided by hugo.
Run:

```sh
$ hugo server -D
```

where the `-D` option is used so drafts are also shown.

A server will be started (likely on localhost:1313). Here is the result:

{{% figure class="image" src="/images/hugo/index.png" title="localhost:1313/" caption="Homepage of the website. configured in `layouts/index.html`." %}}

{{% figure class="image" src="/images/hugo/about.png" title="localhost:1313/about" caption="Single page. configured in `layouts/_default/single.html` with content from `content/about.md`." %}}

{{% figure class="image" src="/images/hugo/post.png" title="localhost:1313/post" caption="List page. configured in `layouts/_default/list.html` and lists single pages within `content/post/`." %}}

{{% figure class="image" src="/images/hugo/helloworld.png" title="localhost:1313/post/helloword" caption="Another example of a single page. Content from `content/post/helloworld.md`." %}}

At this point you can continue editing the all the files mentioned to your liking. Everytime you save your changes the website will automatically reload.

# 6. Publishing the website

Once you're satisfied with your changes, you can generate the static website by running:

```sh
$ hugo
```

This will output all the static files you need into `public/`.
