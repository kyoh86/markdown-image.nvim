# sample

## link

They should NOT be matched

[](link)
[](https://example.com/link)

## images

They should be uploaded and replaced by new URL

![](image) foo
![](image_with_width =3x) foo
![](image_with_size =3x6) foo
![](https://example.com/image_url) foo
![](https://example.com/image_url_with_width =4x) foo
![](https://example.com/image_url_with_size =30x60) foo

## images in a link to other

They should be uploaded and replaced by new URL

[![](image) foo](link)
[![](image_with_width =3x) foo](link)
[![](image_with_size =3x6) foo](link)
[![](https://example.com/image_url) foo](link)
[![](https://example.com/image_url_with_width =4x) foo](link)
[![](https://example.com/image_url_with_size =30x60) foo](link)

## images in a link to the image

They should be uploaded and replaced by new URL, but also link.

[![](image)](image)
[![](image_with_width =3x)](image_with_width)
[![](image_with_size =3x6)](image_with_size)
[![](https://example.com/image_url)](https://example.com/image_url)
[![](https://example.com/image_url_with_width =4x)](https://example.com/image_url_with_width)
[![](https://example.com/image_url_with_size =30x60)](https://example.com/image_url_with_size)

## images in one line

They should be uploaded and replaced by new URL just cursor on.

![](image) ![](image2)
![](image_with_width =3x) ![](image_with_width2 =3x)
![](image_with_size =3x6) ![](image_with_size2 =3x6)
![](https://example.com/image_url) ![](https://example.com/image_url2)
![](https://example.com/image_url_with_width =4x) ![](https://example.com/image_url_with_width2 =4x)
![](https://example.com/image_url_with_size =30x60) ![](https://example.com/image_url_with_size2 =30x60)
