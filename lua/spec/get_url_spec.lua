local imgup = require('imgup')
local not_found = {'', -1, -1}

describe("get_image_url", function()
  it("link1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](link)$')
    assert.are.same(not_found, imgup.get_image_url())
  end)

  it("link2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^[](https://example.com/link)$')
    assert.are.same(not_found, imgup.get_image_url())
  end)

  it("img1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^![](image) foo$')
    assert.are.same({'image', 4, 9}, imgup.get_image_url(), 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image', 4, 9}, imgup.get_image_url(), 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on end paren')
  end)

  it("img2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^![](image_with_width =3x) foo$')
    assert.are.same({'image_with_width', 4, 20}, imgup.get_image_url(), 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image_with_width', 4, 20}, imgup.get_image_url(), 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on end paren')
  end)

  it("img3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^![](image_with_size =3x6) foo$')
    assert.are.same(imgup.get_image_url(), {'image_with_size', 4, 19}, 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same(imgup.get_image_url(), {'image_with_size', 4, 19}, 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(imgup.get_image_url(), not_found, 'not match on end paren')
  end)

  it("img_inthelink1", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image) foo\\](link)$')
    assert.are.same(imgup.get_image_url(), not_found, 'not match on link head')
    vim.cmd[[normal! f!]]
    assert.are.same(imgup.get_image_url(), {'image', 5, 10}, 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same(imgup.get_image_url(), {'image', 5, 10}, 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(imgup.get_image_url(), not_found, 'not match on end paren')
  end)

  it("img_inthelink2", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_width =3x) foo\\](link)$')
    assert.are.same(not_found, imgup.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    assert.are.same({'image_with_width', 5, 21}, imgup.get_image_url(), 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image_with_width', 5, 21}, imgup.get_image_url(), 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_inthelink3", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^\\[![](image_with_size =3x6) foo\\](link)$')
    assert.are.same(not_found, imgup.get_image_url(), 'not match on link head')
    vim.cmd[[normal! f!]]
    assert.are.same({'image_with_size', 5, 20}, imgup.get_image_url(), 'match on head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image_with_size', 5, 20}, imgup.get_image_url(), 'match on tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on end paren')
  end)

  it("img_twice", function()
    vim.cmd[[edit! ./spec/sample.md]]
    vim.fn.search('^!\\[\\](image) !\\[\\](image2)$')
    assert.are.same({'image', 4, 9}, imgup.get_image_url(), 'match on left-head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image', 4, 9}, imgup.get_image_url(), 'match on left-tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on left-end-paren')
    vim.cmd[[normal! l]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on interlude')
    vim.cmd[[normal! f!]]
    assert.are.same({'image2', 15, 21}, imgup.get_image_url(), 'match on right-head')
    vim.cmd[[normal! t)]]
    assert.are.same({'image2', 15, 21}, imgup.get_image_url(), 'match on right-tail')
    vim.cmd[[normal! f)]]
    assert.are.same(not_found, imgup.get_image_url(), 'not match on right-end-paren')
  end)
end)
