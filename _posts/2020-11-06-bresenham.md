---
layout: post
title:  "A variant of Bresenham's line algorithm for edge walk triangle rasterization"
date:   2020-11-06
---

One way to rasterize triangle-based geometry is to use the _edge walk_ method (sometimes also incorrectly referred to as the scanline method). Line by line, we find the line segments bounding our triangle, and we _walk along_ them to determine which pixels of each line are covered by the triangle.

{% figure [caption:"A flat-bottom triangle ([source](http://www.sunshine2k.de/coding/java/TriangleRasterization/TriangleRasterization.html))"] %}
![flat-bottom triangle](../../../images/bresenham/flatbottomtriangle.png)
{% endfigure %}

I will not repeat the basic ideas (sorting vertices by Y, decomposition into a flat bottom triangle and a flat top triangle) -- a good explanation can be found, for example, in the link above. In this post I want to focus solely on how to correctly use Bresenham's line drawing algorithm to walk the triangle edges.

# Coverage rules!

Drawing one triangle is an easy case, and off-by-one errors won't be noticed so easily; furthemore, in absence of anti-aliasing, there can be ambiguity about whether certain edge pixels _should_ be filled or not.

Once having more complex geometry, though, coverage rules become important to ensure that there will be no gaps in the rasterized geometry. It is desirable to also avoid the opposite (one pixel being covered by two adjacent faces), because it is slightly wasteful, and can lead to ugly flickering artifacts as the camera moves around the scene.

For Microsoft's Direct3D 11 graphics API, there is [excellent documentation](https://docs.microsoft.com/en-us/windows/win32/direct3d11/d3d10-graphics-programming-guide-rasterizer-stage-rules) of the conventions that it follows. We shall assume that conventions adopted by leading rendering API for desktop gaming are sound enough for our purpose.

{% figure [caption:"Direct3D coverage rules"] %}
![Direct3D coverage rules](../../../images/bresenham/d3d10-rasterrulestriangle.png)
{% endfigure %}

> Any pixel center which falls inside a triangle is drawn; a pixel is assumed to be inside if it passes the top-left rule. The top-left rule is that a pixel center is defined to lie inside of a triangle if it lies [entirely within the triangle, i.e. not touching any of the edges, or] on the top edge or the left edge of a triangle.
>
> Where:
>
> - A top edge, is an edge that is exactly horizontal and is above the other edges.
> - A left edge, is an edge that is not exactly horizontal and is on the left side of the triangle. A triangle can have one or two left edges.
>
> The top-left rule ensures that adjacent triangles are drawn once.

Let us now formulate the task more exactly:

- triangle given by integer coordinates $(X_1, Y_1)$, $(X_2, Y_2)$, $(X_3, Y_3)$ in screen space
    - no subpixel precision, sorry (maybe next time?)
- viewport originating in the top-left corner, X+ pointing right, Y+ pointing down
- scan the triangle edges line by line
    - for each pixel row $Y$, determine $X_{start}, X_{end}$, to fill pixels satisfying $X_{start} \le X \lt X_{end}$ (note the assymmetry here) compliant with _Triangle Rasterization Rules (Without Multisampling)_ of Direct3D 10/11
- no floating-point operations and no integer division

Note: I use capital letters to denote integer coordinates, e.g. those lying in the top-left corner of a pixel. Lowercase letters stand general coordinates which might lie in the pixel's top-left corner, in its center, or anywhere else.

# Line discretization

Based on the coverage rules, we can now form a mathematic description of the problem, and re-derive our own little Bresenham-like algorithm.

An important realization here is that, although we specify vertex coordinates at pixel corners, the sampling points are in pixel centers. If we describe the triangle edges with their _explicit equations_ (expressing $x$ as a function of $y$), the coverage rule can then be reformulated as follows:

- with respect to the left edge of the triangle, the center of pixel $(X, Y)$ is inside the triangle if it lies on, or to the right of the edge at $$Y + 0.5$$, e.g. if $$X + 0.5 >= x_{left}(Y + 0.5)$$.
- with respect to the right edge of the triangle, the center of pixel $(X, Y)$ is inside the triangle if it lies to the left of the edge at $$Y + 0.5$$, e.g. $$X + 0.5 < x_{right}(Y + 0.5)$$.

For a line defined by points $$a=(x_a, y_a), b=(x_b, y_b)$$, the explicit function can be obtained as:

$$
x(y) = x_a + \frac{y - y_a}{y_b - y_a}(x_b - x_a)
$$

(This function exists as long as the line is not horizontal, e.g. $y_a \ne y_b$, but when processing the edges of flat-top and flat-bottom triangles, we will not encounter any horizontal lines except in degenerate cases.)

This representation gives us a lot of power; given the bounding line in screen space and an $$y$$-cordinate, we can for example find the left-most filled pixel ($X_{left}$) by determining the smallest integer $X_{left}$ that satisfies the inequality

$$
X_{left} + 0.5 \ge x_a + \frac{y - y_a}{y_b - y_a}(x_b - x_a).
$$

(Note that this calculation can be also performed with sub-pixel precision.)

# An efficient algorithm

Of course, as said above, we don't want no stinkin' division (nor fractional numbers), so the initial equation will need some work. First we will discuss the left bounding line segment and assume that $$x_b \ge x_a$$ and $$y_b > y_a$$, e.g. we are going left to right, top to bottom. Let's start by un-generalizing some of the variables: we snap the line vertices to pixel corners, and we test at pixel-center y-coordinates.

$$
X_{left} + 0.5 \ge X_a + \frac{(Y + 0.5) - Y_a}{Y_b - Y_a}(X_b - X_a).
$$

Now we can proceed to eliminate the fractional values and division operation.

$$
2X_{left} + 1 \ge 2X_a + \frac{2Y + 1 - 2Y_a}{Y_b - Y_a}(X_b - X_a),
$$

$$
(2X_{left} + 1)(Y_b - Y_a) \ge 2(Y_b - Y_a)X_a + (2Y + 1 - 2Y_a)(X_b - X_a).
$$

Our goal here is to arrive at an inequality that can be tested for a candidate $$X_{left}$$, plus a recipe to adjust this $$X_{left}$$ until the inequality holds, starting at $$X_a$$. Thus we need to separate the term dependent on $$(X_{left} - X_a)$$:

$$
2(Y_b - Y_a) (X_{left} - X_a) + (Y_b - Y_a) \ge (2Y + 1 - 2Y_a)(X_b - X_a).
$$

At the same time, since we need to track the line over a range of $$Y$$ coordinates, it will be also useful to extract the term dependent on $$(Y - Y_a)$$:

$$
2(Y_b - Y_a) (X_{left} - X_a) + (Y_b - Y_a) - (X_b - X_a) - 2(Y - Y_a)(X_b - X_a) \ge 0.
$$

Alright -- now we can use the insight of Dr. Bresenham to convert the inequality into an iterative algorithm!

In the starting point $$(X_a, Y_a)$$ we store the left side of the inequality into an "error accumulator" variable:

```c+=
E := (Y_b - Y_a) - (X_b - X_a)
```

Then, we check whether $$E \ge 0$$. If this is not the case, we are "lagging behind" the line (we said the line was going left to right, and we start at the left-most, top-most point). Thus, we have to increase $$X_{left}$$ and correspondingly adjust the error accumulator by the x-dependent term of the line inequality. Then we check again and repeat the cycle as many times as needed.

```c++
while E < 0:
    X_left := X_left + 1
    E      := E + 2 * (Y_b - Y_a)
```

At this point our $$X_{left}$$ is valid and we can process one line of the triangle. When done, we will proceed to the next line (until we reach the end of the triangle). Again we must not forget to adjust the error term.

```c++
Y := Y + 1
E := E - 2 * (X_b - X_a)
```

In sum, the structure of the code to scan one edge might look like this:

```c++
int E = (Y_b - Y_a) - (X_b - X_a);
int X_left = X_a;

for (int Y = Y_a; Y < Y_b; Y++) {
    while (E < 0) {
        X_left ++;
        E += 2 * (Y_b - Y_a);
    }

    ...per-line processing goes here...

    E -= 2 * (X_b - X_a);
}
```

#### Right edge

Now, what about the right edge of the triangle? The answer is actually hidden in what was said at the beginning. Between adjacent faces, there shall be neither any gaps, nor overlap. That means that the right edge of face A has to be calculated in exactly the same way as the left edge of face B, but shared pixels ought to be covered by only one of the faces. The consequence is that we scan the right edge in the same way as the left edge, and we only fill pixels where $X < X_{right}$.

# Going Negative

We have now solved the case of $$x_b \ge x_a$$. How do we deal with the opposite?

Again, we must satisfy the inequality

$$
X_{left} + 0.5 \ge X_a + \frac{(Y + 0.5) - Y_a}{Y_b - Y_a}(X_b - X_a),
$$

but this time the worry is not that "the edge will run away to the right"; instead, it can happen that "we will not be in the leftmost possible position". An intuitive solution is then to check _one pixel to the left_ (so $$X_{left} - 0.5$$), and keep decreasing $$X_{left}$$ until that test pixel is just barely out of bounds.

**This is different from what most "Bresenham tutorials" on the internet will tell you to do** -- but it is crucial for ensuring that only pixels lying in the triangle (those with barycentric coordinates $s \ge 0, t \ge 0, s + t \le 1$) will be filled, which in turn is important for per-pixel interpolation of values like texture coordinates.

In our algorithm, we can simply include a bias in the initialization of the error term. We *pre-subtract* one worth of x-increment, which is $$2(Y_b - Y_a)$$. In terms of code:

```c++
int E = -(Y_b - Y_a) - (X_b - X_a);
int X_left = X_a;

for (int Y = Y_a; Y < Y_b; Y++) {
    while (E >= 0) {
        X_left --;
        E -= 2 * (Y_b - Y_a);
    }

    ...per-line processing goes here...

    E -= 2 * (X_b - X_a);       // note that the right-side expression
                                // is now negative, so we *increase* E
}
```

# But does it work?

What could be better proof than a screenshot in action?!

{% figure [caption:"Triangle rasterization according to the algorithm described herein. Textures and some geometry are courtesy of TES: Daggerfall"] %}
![Screenshot](../../../images/bresenham/not-daggerfall.png)
{% endfigure %}
