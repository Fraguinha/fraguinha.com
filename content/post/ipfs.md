---
title: "IPFS - InterPlanetary File System"
description: "How to host your website on ipfs."
date: 2022-08-27T00:24:13+01:00
draft: false
---

The [InterPlanetary File System](https://ipfs.tech) is a protocol, hypermedia and file sharing peer-to-peer network for storing and sharing data in a distributed file system.

# 1. Hosting on ipfs

After you have ipfs installed in your system, you will need to initialize your node.

{{< highlight zsh >}}
$ ipfs init
{{< / highlight >}}

Create a directory where your website files will be stored such as `my-ipfs-website`.
Within it, write a simple `index.html` file with the following content:

{{< highlight html >}}
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Helloworld</title>
</head>
<body>
  <h1>Helloworld</h1>
</body>
</html>
{{< / highlight >}}

We are now ready to start hosting our content on ipfs.
Let's add (and pin) the file we've just created on our node by running:

{{< highlight zsh >}}
$ ipfs add index.html
{{< / highlight >}}

if your `index.html` is the same as the one provided you should get output that looks exactly like this:

{{< highlight text >}}
added QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE index.html
 121 B / 121 B [=======================================================] 100.00%
{{< / highlight >}}

Your page is now hosted on ipfs with the CID: `QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE`

# 2. Reading from ipfs

Now that your content is hosted on ipfs you can access it by running:

{{< highlight zsh >}}
$ ipfs cat QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE
{{< / highlight >}}

or by navigating to [ipfs.io/ipfs/QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE](https://ipfs.io/ipfs/QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE) on your browser.

# 3. IPNS

By using IPNS we will be able to change the content of our website while only keeping track of a single name.
Let's add `my-ipfs-website` to ipfs:

{{< highlight zsh >}}
$ ipfs add -r .
{{< / highlight >}}

If you've been following along so far the output should look like:

{{< highlight text >}}
added QmWoKHuKnRYYAjFXTfYTNAv7notts7Lheozkvf8agCKwuE my-ipfs-website/index.html
added QmdHZPZV8aMjrCMvYfksgfbkQd1bKkYZAKM5K4GrVTRuwq my-ipfs-website
 121 B / 121 B [=======================================================] 100.00%
{{< / highlight >}}

We can now publish all the content of `my-ipfs-website` with the CID: `QmdHZPZV8aMjrCMvYfksgfbkQd1bKkYZAKM5K4GrVTRuwq` to IPNS by running:

{{< highlight zsh >}}
$ ipfs name publish QmdHZPZV8aMjrCMvYfksgfbkQd1bKkYZAKM5K4GrVTRuwq
{{< / highlight >}}

This will use your node's private key.
Your output will be slightly different but similar to:

{{< highlight text >}}
Published to k51qzi5uqu5dgb363ilzyyyj360gspxvm2uj0jrtdnktowmu8318z6tpxsfvqj:
    /ipfs/QmdHZPZV8aMjrCMvYfksgfbkQd1bKkYZAKM5K4GrVTRuwq
{{< / highlight >}}

By running the previous two commands each time you make changes to your website, you can ensure that

Name: `k51qzi5uqu5dgb363ilzyyyj360gspxvm2uj0jrtdnktowmu8318z6tpxsfvqj`

always has the latest version of your content.

# 4. DNSLink (Bonus)

If you have a domain name on the web already you can point it to IPFS by adding a TXT record to your domain similar to:

| Type | Name                   | Content                                                                        |
| ---- | ---------------------- | ------------------------------------------------------------------------------ |
| TXT  | _dnslink.`example.com` | dnslink=/ipns/`k51qzi5uqu5dgb363ilzyyyj360gspxvm2uj0jrtdnktowmu8318z6tpxsfvqj` |

Making sure to edit `example.com` with your own domain name and `k51qzi5uqu5dgb363ilzyyyj360gspxvm2uj0jrtdnktowmu8318z6tpxsfvqj` with the name you got from your previous command.

# 5. Pinata (Bonus)

So far, your content is only hosted on your personal ipfs node.
By using a pinning service like pinata you can ensure your content remains accessible on ipfs even when your node is down.

Start by navigating to [pinata](https://www.pinata.cloud/), registering an account and creating an API key making sure to take note of your `JWT` token.

From there simply add your pinata credentials to ipfs:

{{< highlight zsh >}}
$ ipfs pin remote service add pinata https://api.pinata.cloud/psa [JWT]
{{< / highlight >}}

You can now use the following command to pin your website to pinata:

{{< highlight zsh >}}
$ ipfs pin remote add --service=pinata --name=my-ipfs-website QmdHZPZV8aMjrCMvYfksgfbkQd1bKkYZAKM5K4GrVTRuwq
{{< / highlight >}}
