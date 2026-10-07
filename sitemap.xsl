<?xml version="1.0" encoding="UTF-8"?>
<!--
  DataLab · Vista legible de los sitemaps XML de wearedatalab.com (XSLT 1.0, la aplica el navegador).

  · Índice (/sitemap.xml): resumen (sitemaps, nº de URL e imágenes por sitemap, totales por idioma) y, debajo,
    TODAS las URL agrupadas por idioma y sección. Cada sitemap hijo se carga con document() por su RUTA relativa
    (substring-after del dominio), así la vista funciona igual en producción y en localhost.
  · Sitemap hijo (/sitemap-{es|en}-{sección}.xml): tabla de URL, alternativas de idioma (hreflang), nº de imágenes
    y última modificación. El idioma y la sección salen del comentario «dl-sitemap lang=… section=…» del XML.
  · Sin estilos ni scripts en línea (la CSP de estas respuestas solo permite 'self'): todo el estilo está en
    /sitemap.css y la fuente es la Raleway autoalojada del sitio.
  Los buscadores ignoran esta hoja: leen el XML tal cual. Fuente: src/seo/sitemap.xsl (la copia build.py a dist/).
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sm="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
  exclude-result-prefixes="sm xhtml image">

  <xsl:output method="html" encoding="UTF-8" indent="no" doctype-system="about:legacy-compat"/>

  <!-- Metadatos del sitemap hijo, tomados de su comentario «dl-sitemap lang=es section=servicios» -->
  <xsl:variable name="meta" select="normalize-space(/comment()[starts-with(normalize-space(.), 'dl-sitemap')])"/>
  <xsl:variable name="meta-lang" select="substring-before(substring-after($meta, 'lang='), ' ')"/>
  <xsl:variable name="meta-sec" select="substring-after($meta, 'section=')"/>
  <!-- Idioma de la interfaz: los sitemaps hijos en inglés se muestran en inglés; el índice, en español (x-default) -->
  <xsl:variable name="ui"><xsl:choose><xsl:when test="$meta-lang = 'en'">en</xsl:when><xsl:otherwise>es</xsl:otherwise></xsl:choose></xsl:variable>
  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

  <!-- ============================================================ Página -->
  <xsl:template match="/">
    <html lang="{$ui}">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta name="robots" content="noindex, follow"/>
        <meta name="color-scheme" content="dark"/>
        <title>
          <xsl:choose>
            <xsl:when test="sm:sitemapindex">Sitemap XML · todas las URL · wearedatalab.com</xsl:when>
            <xsl:otherwise>
              <xsl:text>Sitemap · </xsl:text>
              <xsl:call-template name="sec-label"><xsl:with-param name="s" select="$meta-sec"/></xsl:call-template>
              <xsl:text> (</xsl:text>
              <xsl:call-template name="lang-label"><xsl:with-param name="l" select="$meta-lang"/></xsl:call-template>
              <xsl:text>) · wearedatalab.com</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </title>
        <link rel="stylesheet" href="/sitemap.css"/>
      </head>
      <body>
        <header class="top">
          <div class="wrap top__in">
            <xsl:choose>
              <xsl:when test="$ui = 'en'">
                <a class="brand" href="/en/" aria-label="DataLab, go to the home page">DATA<b>LAB</b></a>
                <span class="pill">XML sitemap</span>
                <nav class="top__nav" aria-label="Sitemaps">
                  <a href="/sitemap.xml">Sitemap index</a>
                  <a href="/en/sitemap/">Human-readable sitemap</a>
                  <a href="/mapa-del-sitio/" hreflang="es" lang="es">Mapa del sitio (español)</a>
                </nav>
              </xsl:when>
              <xsl:otherwise>
                <a class="brand" href="/" aria-label="DataLab, ir al inicio">DATA<b>LAB</b></a>
                <span class="pill">Sitemap XML</span>
                <nav class="top__nav" aria-label="Mapas del sitio">
                  <a href="/sitemap.xml">Índice</a>
                  <a href="/mapa-del-sitio/">Mapa del sitio para personas</a>
                  <a href="/en/sitemap/" hreflang="en" lang="en">Sitemap (English)</a>
                </nav>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </header>
        <main class="wrap">
          <xsl:apply-templates select="sm:sitemapindex | sm:urlset"/>
        </main>
        <footer class="wrap foot">
          <xsl:choose>
            <xsl:when test="$ui = 'en'">
              <p>Google, Bing and AI search engines read these files to discover the site's pages; this view is for people only. Format: <a href="https://www.sitemaps.org/protocol.html" rel="noopener noreferrer">sitemaps.org 0.9</a> with language alternates (hreflang) and images.</p>
            </xsl:when>
            <xsl:otherwise>
              <p>Estos archivos los leen Google, Bing y los motores de IA para descubrir las páginas del sitio; esta vista es solo para personas. Formato <a href="https://www.sitemaps.org/protocol.html" rel="noopener noreferrer">sitemaps.org 0.9</a> con alternativas de idioma (hreflang) e imágenes.</p>
            </xsl:otherwise>
          </xsl:choose>
        </footer>
      </body>
    </html>
  </xsl:template>

  <!-- ============================================================ Índice -->
  <xsl:template match="sm:sitemapindex">
    <xsl:variable name="es" select="sm:sitemap[contains(sm:loc, '/sitemap-es-')]"/>
    <xsl:variable name="en" select="sm:sitemap[contains(sm:loc, '/sitemap-en-')]"/>
    <xsl:variable name="n-es"><xsl:call-template name="sum"><xsl:with-param name="maps" select="$es"/></xsl:call-template></xsl:variable>
    <xsl:variable name="n-en"><xsl:call-template name="sum"><xsl:with-param name="maps" select="$en"/></xsl:call-template></xsl:variable>
    <xsl:variable name="n-img"><xsl:call-template name="sum"><xsl:with-param name="maps" select="sm:sitemap"/><xsl:with-param name="what" select="'img'"/></xsl:call-template></xsl:variable>

    <section class="hero">
      <p class="eyebrow">Índice de sitemaps</p>
      <h1>Todas las URL de wearedatalab.com</h1>
      <p class="lead">El sitemap está dividido por idioma y por sección para medir en Search Console cuántas páginas de cada grupo indexa Google. Solo incluye URL canónicas e indexables, con su fecha real de última modificación.</p>
    </section>

    <ul class="stats" role="list">
      <li><b><xsl:value-of select="$n-es + $n-en"/></b><span>URL indexables</span></li>
      <li><b><xsl:value-of select="$n-es"/></b><span>en español</span></li>
      <li><b><xsl:value-of select="$n-en"/></b><span>en inglés</span></li>
      <li><b><xsl:value-of select="count(sm:sitemap)"/></b><span>sitemaps</span></li>
      <li><b><xsl:value-of select="$n-img"/></b><span>imágenes</span></li>
      <li>
        <b><xsl:for-each select="sm:sitemap/sm:lastmod"><xsl:sort select="." order="descending"/><xsl:if test="position() = 1"><xsl:call-template name="date"><xsl:with-param name="d" select="."/></xsl:call-template></xsl:if></xsl:for-each></b>
        <span>última modificación</span>
      </li>
    </ul>

    <section class="block" aria-labelledby="h-maps">
      <h2 id="h-maps">Sitemaps</h2>
      <table class="maps">
        <thead>
          <tr><th scope="col">Sitemap</th><th scope="col">Idioma</th><th scope="col">Sección</th><th scope="col" class="n">URL</th><th scope="col" class="n">Imágenes</th><th scope="col">Última modificación</th></tr>
        </thead>
        <tbody>
          <xsl:for-each select="sm:sitemap">
            <xsl:variable name="p" select="concat('/', substring-after(substring-after(sm:loc, '://'), '/'))"/>
            <xsl:variable name="key" select="substring-before(substring-after($p, '/sitemap-'), '.xml')"/>
            <xsl:variable name="doc" select="document($p)"/>
            <tr>
              <td class="u" data-label="Sitemap"><a href="{$p}" title="{sm:loc}"><xsl:value-of select="substring-after($p, '/')"/></a></td>
              <td data-label="Idioma"><xsl:call-template name="lang-label"><xsl:with-param name="l" select="substring-before($key, '-')"/></xsl:call-template></td>
              <td data-label="Sección"><a href="#s-{$key}"><xsl:call-template name="sec-label"><xsl:with-param name="s" select="substring-after($key, '-')"/></xsl:call-template></a></td>
              <td class="n" data-label="URL"><xsl:value-of select="count($doc/sm:urlset/sm:url)"/></td>
              <td class="n" data-label="Imágenes"><xsl:value-of select="count($doc/sm:urlset/sm:url/image:image)"/></td>
              <td class="d" data-label="Última modificación"><xsl:call-template name="date"><xsl:with-param name="d" select="sm:lastmod"/></xsl:call-template></td>
            </tr>
          </xsl:for-each>
        </tbody>
        <tfoot>
          <tr><th scope="row" colspan="3">Total</th><td class="n" data-label="URL"><xsl:value-of select="$n-es + $n-en"/></td><td class="n" data-label="Imágenes"><xsl:value-of select="$n-img"/></td><td></td></tr>
        </tfoot>
      </table>
    </section>

    <section class="block" aria-labelledby="h-all">
      <h2 id="h-all">Todas las URL, por idioma y sección</h2>
      <xsl:call-template name="lang-block"><xsl:with-param name="maps" select="$es"/><xsl:with-param name="l" select="'es'"/><xsl:with-param name="n" select="$n-es"/></xsl:call-template>
      <xsl:call-template name="lang-block"><xsl:with-param name="maps" select="$en"/><xsl:with-param name="l" select="'en'"/><xsl:with-param name="n" select="$n-en"/></xsl:call-template>
    </section>
  </xsl:template>

  <!-- Bloque de un idioma en el índice: navegación por secciones + una tabla por sitemap hijo -->
  <xsl:template name="lang-block">
    <xsl:param name="maps"/>
    <xsl:param name="l"/>
    <xsl:param name="n"/>
    <xsl:if test="$maps">
      <section class="lang" id="lang-{$l}" aria-labelledby="h-lang-{$l}">
        <h3 class="lang__h" id="h-lang-{$l}">
          <xsl:call-template name="lang-label"><xsl:with-param name="l" select="$l"/></xsl:call-template>
          <small><xsl:value-of select="$n"/> URL</small>
        </h3>
        <nav class="chips" aria-label="Secciones">
          <xsl:for-each select="$maps">
            <xsl:variable name="p" select="concat('/', substring-after(substring-after(sm:loc, '://'), '/'))"/>
            <xsl:variable name="key" select="substring-before(substring-after($p, '/sitemap-'), '.xml')"/>
            <a href="#s-{$key}">
              <xsl:call-template name="sec-label"><xsl:with-param name="s" select="substring-after($key, '-')"/></xsl:call-template>
              <small><xsl:value-of select="count(document($p)/sm:urlset/sm:url)"/></small>
            </a>
          </xsl:for-each>
        </nav>
        <xsl:for-each select="$maps">
          <xsl:variable name="p" select="concat('/', substring-after(substring-after(sm:loc, '://'), '/'))"/>
          <xsl:variable name="key" select="substring-before(substring-after($p, '/sitemap-'), '.xml')"/>
          <xsl:variable name="urls" select="document($p)/sm:urlset/sm:url"/>
          <section class="group" id="s-{$key}" aria-labelledby="h-s-{$key}">
            <h4 class="group__h" id="h-s-{$key}">
              <xsl:call-template name="sec-label"><xsl:with-param name="s" select="substring-after($key, '-')"/></xsl:call-template>
              <small><xsl:value-of select="count($urls)"/> URL · <a href="{$p}"><xsl:value-of select="substring-after($p, '/')"/></a></small>
            </h4>
            <p class="group__d"><xsl:call-template name="sec-desc"><xsl:with-param name="s" select="substring-after($key, '-')"/></xsl:call-template></p>
            <xsl:call-template name="url-table"><xsl:with-param name="urls" select="$urls"/><xsl:with-param name="l" select="$l"/></xsl:call-template>
          </section>
        </xsl:for-each>
      </section>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================ Sitemap hijo -->
  <xsl:template match="sm:urlset">
    <p class="back"><a href="/sitemap.xml"><xsl:choose><xsl:when test="$ui = 'en'">← Sitemap index</xsl:when><xsl:otherwise>← Índice de sitemaps</xsl:otherwise></xsl:choose></a></p>
    <section class="hero">
      <p class="eyebrow"><xsl:choose><xsl:when test="$ui = 'en'">XML sitemap</xsl:when><xsl:otherwise>Sitemap XML</xsl:otherwise></xsl:choose> · <xsl:call-template name="lang-label"><xsl:with-param name="l" select="$meta-lang"/></xsl:call-template></p>
      <h1><xsl:call-template name="sec-label"><xsl:with-param name="s" select="$meta-sec"/></xsl:call-template></h1>
      <p class="lead"><xsl:call-template name="sec-desc"><xsl:with-param name="s" select="$meta-sec"/></xsl:call-template></p>
    </section>
    <ul class="stats" role="list">
      <li><b><xsl:value-of select="count(sm:url)"/></b><span><xsl:choose><xsl:when test="$ui = 'en'">URLs</xsl:when><xsl:otherwise>URL</xsl:otherwise></xsl:choose></span></li>
      <li><b><xsl:value-of select="count(sm:url/image:image)"/></b><span><xsl:choose><xsl:when test="$ui = 'en'">images</xsl:when><xsl:otherwise>imágenes</xsl:otherwise></xsl:choose></span></li>
      <li><b><xsl:value-of select="count(sm:url[xhtml:link])"/></b><span><xsl:choose><xsl:when test="$ui = 'en'">with a translation</xsl:when><xsl:otherwise>con traducción</xsl:otherwise></xsl:choose></span></li>
      <li>
        <b><xsl:for-each select="sm:url/sm:lastmod"><xsl:sort select="." order="descending"/><xsl:if test="position() = 1"><xsl:call-template name="date"><xsl:with-param name="d" select="."/></xsl:call-template></xsl:if></xsl:for-each></b>
        <span><xsl:choose><xsl:when test="$ui = 'en'">last modified</xsl:when><xsl:otherwise>última modificación</xsl:otherwise></xsl:choose></span>
      </li>
    </ul>
    <section class="block" aria-label="URL">
      <xsl:call-template name="url-table"><xsl:with-param name="urls" select="sm:url"/><xsl:with-param name="l" select="$meta-lang"/></xsl:call-template>
    </section>
  </xsl:template>

  <!-- ============================================================ Tabla de URL -->
  <xsl:template name="url-table">
    <xsl:param name="urls"/>
    <xsl:param name="l"/>
    <table class="urls">
      <thead>
        <xsl:choose>
          <xsl:when test="$ui = 'en'"><tr><th scope="col">URL</th><th scope="col">Languages</th><th scope="col" class="n">Images</th><th scope="col">Last modified</th></tr></xsl:when>
          <xsl:otherwise><tr><th scope="col">URL</th><th scope="col">Idiomas</th><th scope="col" class="n">Imágenes</th><th scope="col">Última modificación</th></tr></xsl:otherwise>
        </xsl:choose>
      </thead>
      <tbody>
        <xsl:for-each select="$urls">
          <xsl:variable name="host" select="substring-before(substring-after(sm:loc, '://'), '/')"/>
          <xsl:variable name="p" select="concat('/', substring-after(substring-after(sm:loc, '://'), '/'))"/>
          <tr>
            <td class="u"><a href="{$p}" title="{sm:loc}"><span class="host"><xsl:value-of select="$host"/></span><xsl:value-of select="$p"/></a></td>
            <td class="alt">
              <xsl:attribute name="data-label"><xsl:choose><xsl:when test="$ui = 'en'">Languages</xsl:when><xsl:otherwise>Idiomas</xsl:otherwise></xsl:choose></xsl:attribute>
              <xsl:choose>
                <xsl:when test="xhtml:link[@hreflang != 'x-default']">
                  <xsl:for-each select="xhtml:link[@hreflang != 'x-default']">
                    <a class="hl" href="{concat('/', substring-after(substring-after(@href, '://'), '/'))}" hreflang="{@hreflang}" title="{@href}">
                      <xsl:if test="@href = ../sm:loc"><xsl:attribute name="aria-current">true</xsl:attribute></xsl:if>
                      <xsl:value-of select="translate(@hreflang, $lower, $upper)"/>
                    </a>
                  </xsl:for-each>
                  <xsl:variable name="xd" select="xhtml:link[@hreflang = 'x-default']/@href"/>
                  <xsl:if test="$xd">
                    <span class="xd" title="x-default: {$xd}">x-default → <xsl:value-of select="translate(xhtml:link[@hreflang != 'x-default' and @href = $xd]/@hreflang, $lower, $upper)"/></span>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise><span class="solo"><xsl:choose><xsl:when test="$ui = 'en'"><xsl:value-of select="translate($l, $lower, $upper)"/> only</xsl:when><xsl:otherwise>Solo <xsl:value-of select="translate($l, $lower, $upper)"/></xsl:otherwise></xsl:choose></span></xsl:otherwise>
              </xsl:choose>
            </td>
            <td class="n">
              <xsl:attribute name="data-label"><xsl:choose><xsl:when test="$ui = 'en'">Images</xsl:when><xsl:otherwise>Imágenes</xsl:otherwise></xsl:choose></xsl:attribute>
              <xsl:value-of select="count(image:image)"/>
            </td>
            <td class="d">
              <xsl:attribute name="data-label"><xsl:choose><xsl:when test="$ui = 'en'">Last modified</xsl:when><xsl:otherwise>Última modificación</xsl:otherwise></xsl:choose></xsl:attribute>
              <time datetime="{sm:lastmod}"><xsl:call-template name="date"><xsl:with-param name="d" select="sm:lastmod"/></xsl:call-template></time>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- ============================================================ Utilidades -->
  <!-- Suma de URL (what='url') o imágenes (what='img') de una lista de sitemaps hijos (recursiva: XSLT 1.0) -->
  <xsl:template name="sum">
    <xsl:param name="maps"/>
    <xsl:param name="what" select="'url'"/>
    <xsl:param name="acc" select="0"/>
    <xsl:choose>
      <xsl:when test="$maps">
        <xsl:variable name="doc" select="document(concat('/', substring-after(substring-after($maps[1]/sm:loc, '://'), '/')))"/>
        <xsl:variable name="n">
          <xsl:choose>
            <xsl:when test="$what = 'img'"><xsl:value-of select="count($doc/sm:urlset/sm:url/image:image)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="count($doc/sm:urlset/sm:url)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="sum">
          <xsl:with-param name="maps" select="$maps[position() &gt; 1]"/>
          <xsl:with-param name="what" select="$what"/>
          <xsl:with-param name="acc" select="$acc + $n"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$acc"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lang-label">
    <xsl:param name="l"/>
    <xsl:choose>
      <xsl:when test="$ui = 'en' and $l = 'es'">Spanish</xsl:when>
      <xsl:when test="$ui = 'en' and $l = 'en'">English</xsl:when>
      <xsl:when test="$l = 'es'">Español</xsl:when>
      <xsl:when test="$l = 'en'">Inglés</xsl:when>
      <xsl:otherwise><xsl:value-of select="$l"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="sec-label">
    <xsl:param name="s"/>
    <xsl:variable name="k">
      <xsl:choose>
        <xsl:when test="$s = 'pages'">paginas</xsl:when>
        <xsl:when test="$s = 'services'">servicios</xsl:when>
        <xsl:when test="$s = 'casos-de-exito' or $s = 'case-studies'">casos</xsl:when>
        <xsl:when test="$s = 'work'">proyectos</xsl:when>
        <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ui = 'en'">
        <xsl:choose>
          <xsl:when test="$k = 'paginas'">Main pages</xsl:when>
          <xsl:when test="$k = 'servicios'">Services</xsl:when>
          <xsl:when test="$k = 'bogota'">Bogotá, Colombia</xsl:when>
          <xsl:when test="$k = 'casos'">Case studies</xsl:when>
          <xsl:when test="$k = 'proyectos'">Work (portfolio)</xsl:when>
          <xsl:when test="$k = 'blog'">Blog</xsl:when>
          <xsl:otherwise><xsl:value-of select="$k"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$k = 'paginas'">Páginas principales</xsl:when>
          <xsl:when test="$k = 'servicios'">Servicios</xsl:when>
          <xsl:when test="$k = 'bogota'">Bogotá</xsl:when>
          <xsl:when test="$k = 'casos'">Casos de éxito</xsl:when>
          <xsl:when test="$k = 'proyectos'">Proyectos (portafolio)</xsl:when>
          <xsl:when test="$k = 'blog'">Blog</xsl:when>
          <xsl:otherwise><xsl:value-of select="$k"/></xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Cada sección empieza por su índice (hub), como en el mapa del sitio HTML -->
  <xsl:template name="sec-desc">
    <xsl:param name="s"/>
    <xsl:variable name="k">
      <xsl:choose>
        <xsl:when test="$s = 'pages'">paginas</xsl:when>
        <xsl:when test="$s = 'services'">servicios</xsl:when>
        <xsl:when test="$s = 'casos-de-exito' or $s = 'case-studies'">casos</xsl:when>
        <xsl:when test="$s = 'work'">proyectos</xsl:when>
        <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ui = 'en'">
        <xsl:choose>
          <xsl:when test="$k = 'paginas'">Home page, about, contact, human-readable sitemap and legal documents.</xsl:when>
          <xsl:when test="$k = 'servicios'">The services index, then one page per service in the order of its family: growth, content, technology and staff augmentation.</xsl:when>
          <xsl:when test="$k = 'bogota'">The Bogotá page and the services with local information for companies working with a team in Colombia.</xsl:when>
          <xsl:when test="$k = 'casos'">The case studies index, then one case study per page in alphabetical order by client.</xsl:when>
          <xsl:when test="$k = 'proyectos'">The portfolio and its indexable deliverable types.</xsl:when>
          <xsl:when test="$k = 'blog'">The blog index, then the articles from newest to oldest.</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$k = 'paginas'">Inicio, nosotros, contacto, mapa del sitio para personas y documentos legales.</xsl:when>
          <xsl:when test="$k = 'servicios'">El índice de servicios y una página por servicio, en el orden de sus familias: crecimiento, contenido, tecnología y Staff Augmentation.</xsl:when>
          <xsl:when test="$k = 'bogota'">La página de Bogotá y los servicios con información local para empresas de Bogotá.</xsl:when>
          <xsl:when test="$k = 'casos'">El índice de casos y un caso de éxito por página, en orden alfabético por cliente.</xsl:when>
          <xsl:when test="$k = 'proyectos'">El portafolio y sus tipos de entregable indexables.</xsl:when>
          <xsl:when test="$k = 'blog'">El índice del blog y sus artículos, del más reciente al más antiguo.</xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 2026-09-26 → 26 sep 2026 (ES) · Sep 26, 2026 (EN) -->
  <xsl:template name="date">
    <xsl:param name="d"/>
    <xsl:variable name="m" select="number(substring($d, 6, 2))"/>
    <xsl:choose>
      <xsl:when test="$ui = 'en'">
        <xsl:value-of select="substring('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', ($m - 1) * 4 + 1, 3)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="number(substring($d, 9, 2))"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="substring($d, 1, 4)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(substring($d, 9, 2))"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="substring('ene feb mar abr may jun jul ago sep oct nov dic ', ($m - 1) * 4 + 1, 3)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="substring($d, 1, 4)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
