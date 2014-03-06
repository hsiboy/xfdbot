<?xml version="1.0" encoding="UTF-8"?>
<!--		Transforms RSS documents into BBXML messages for display on Betabrite signs. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                              xmlns:rdf09="http://my.netscape.com/rdf/simple/0.9/"
                              xmlns:rss10="http://purl.org/rss/1.0/"
                              xmlns:a="urn:bbxml:rss:lookup"
                              xmlns:b="urn:bbxml:cctray:lookup"
                              exclude-result-prefixes="rdf rdf09 a b rss10">
	<xsl:output method="xml"/>
	<xsl:output indent="yes"/>
	<xsl:strip-space elements="*"/>
	<!-- suppress default output -->
	<xsl:template match="text()|@*"/>
	<xsl:param name="text-label"/>
	<xsl:param name="maxitems"/>
	<xsl:param name="color"/>
	<xsl:param name="minPubDate"/>
	<xsl:template name="lpad">
		<xsl:param name="str"/>
		<xsl:param name="len"/>
		<xsl:param name="chr"/>
		<xsl:choose>
			<xsl:when test="string-length($str) &lt; $len">
				<xsl:call-template name="lpad">
					<xsl:with-param name="str" select="concat($chr, $str)"/>
					<xsl:with-param name="len" select="$len"/>
					<xsl:with-param name="chr" select="$chr"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- RDF 1.0 -->
	<xsl:template match="/rdf:RDF[rss10:channel]">
		<xsl:element name="alphasign">
			<xsl:apply-templates select="rss10:channel"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="rss10:channel">
		<xsl:element name="string">
			<xsl:attribute name="label"><xsl:value-of select="$text-label"/></xsl:attribute>
			<xsl:attribute name="mode">rotate</xsl:attribute>
			<xsl:if test="string-length($color) &gt; 0">
				<xsl:element name="yellow"/>
			</xsl:if>

			<xsl:element name="msg">
				<xsl:element name="fancy7"/>
				<xsl:value-of select="rss10:title"/>
				<xsl:text>: </xsl:text>
				<xsl:element name="standard7"/>
				<xsl:element name="green"/>
			</xsl:element>
			<xsl:apply-templates select="/rdf:RDF/rss10:item[position() &lt;= $maxitems]"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="/rdf:RDF/rss10:item">
		<xsl:element name="msg">
			<xsl:value-of select="rss10:title"/>
			<xsl:text> </xsl:text>
			<xsl:element name="callDots">
			 <xsl:attribute name="label">D</xsl:attribute>
			 </xsl:element>
			 <xsl:text> </xsl:text>
		</xsl:element>
	</xsl:template>

	<!-- RSS -->
	<xsl:template match="/rss">
		<xsl:element name="alphasign">
			<xsl:apply-templates select="channel"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="/rss/channel">
		<xsl:element name="string">
			<xsl:attribute name="label"><xsl:value-of select="$text-label"/></xsl:attribute>
			<xsl:element name="speed5"/>
				<xsl:element name="yellow"/>
			<xsl:element name="msg">
				<xsl:value-of select="title"/>
				<xsl:text>: </xsl:text>
				<xsl:element name="green"/>
			</xsl:element>
			<xsl:apply-templates select="item[position() &lt;= $maxitems]"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="/rss/channel/item">
		<xsl:variable name="pubDate">
			<xsl:apply-templates select="pubDate"/>
		</xsl:variable>
		<xsl:if test="not(number($pubDate) &lt; number($minPubDate))">
			<xsl:element name="msg">
				<xsl:value-of select="title"/>
				<xsl:text> </xsl:text>
			<xsl:element name="callDots">
			 <xsl:attribute name="label">D</xsl:attribute>
			 </xsl:element>
				<xsl:text> </xsl:text>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="/rss/channel/item/pubDate">
		<!-- Wed, 11 Mar 2009 07:31:00 GMT -->
		<!-- Thu, 21 Jul 2005 12:00:00 GMT -->
		<!-- Thu, 1 Jul 2005 12:00:00 GMT -->
		<!-- Thu, 1 Jul 2005 2:00:00 GMT -->
		<xsl:variable name="dd">
			<xsl:call-template name="lpad">
				<xsl:with-param name="str">
					<xsl:value-of select="normalize-space(substring(.,6,2))"/>
				</xsl:with-param>
				<xsl:with-param name="len">2</xsl:with-param>
				<xsl:with-param name="chr">0</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat(normalize-space(substring(.,12,5)),document('')//a:monthLookup/a:month[@name = normalize-space(substring(current(),8,4))]/@value,$dd)"/>
		<!-- 20050721 -->
		<!-- 20050701 -->
	</xsl:template>
	
	<a:monthLookup>
		<a:month name="Jan" value="01"/>
		<a:month name="Feb" value="02"/>
		<a:month name="Mar" value="03"/>
		<a:month name="Apr" value="04"/>
		<a:month name="May" value="05"/>
		<a:month name="Jun" value="06"/>
		<a:month name="Jul" value="07"/>
		<a:month name="Aug" value="08"/>
		<a:month name="Sep" value="09"/>
		<a:month name="Oct" value="10"/>
		<a:month name="Nov" value="11"/>
		<a:month name="Dec" value="12"/>
	</a:monthLookup>
	
	
	<!-- cctray.xml -->
	<xsl:template match="/Projects">
		<xsl:element name="alphasign">
		<xsl:element name="string">
			<xsl:attribute name="label"><xsl:value-of select="$text-label"/></xsl:attribute>
			<xsl:apply-templates select="Project"/>
		</xsl:element>
		</xsl:element>
	</xsl:template>
	

		
	
	<xsl:template match="/Projects/Project[@name='autotrader-branch :: build']|/Projects/Project[@name='autotrader-trunk :: build']|/Projects/Project[@name='autotrader-jmeter-performance :: run-performance-test']">

<!-- 2 beep or not 2 beep -->
<!--
			<xsl:choose>
			<xsl:when test="@lastBuildStatus='Failure'">
				
							 <xsl:element name="beep">
				   <xsl:attribute name="frequency">0</xsl:attribute>
				   <xsl:attribute name="duration">1</xsl:attribute>
				   <xsl:attribute name="repeat">4</xsl:attribute>
				 </xsl:element>
			</xsl:when>
			<xsl:when test="@lastBuildStatus='Exception'">
					 <xsl:element name="beep">
				   <xsl:attribute name="frequency">0</xsl:attribute>
				   <xsl:attribute name="duration">1</xsl:attribute>
				   <xsl:attribute name="repeat">4</xsl:attribute>
				 </xsl:element>
			</xsl:when>
			<xsl:when test="@lastBuildStatus='Unknown'">
					 <xsl:element name="beep">
				   <xsl:attribute name="frequency">0</xsl:attribute>
				   <xsl:attribute name="duration">1</xsl:attribute>
				   <xsl:attribute name="repeat">4</xsl:attribute>
				 </xsl:element>
				 </xsl:when>
		</xsl:choose>
-->

		<xsl:element name="msg">
		<xsl:element name="mode">
		 <xsl:attribute name="position">top</xsl:attribute>
		<xsl:attribute name="display">hold</xsl:attribute>
	</xsl:element>
		<xsl:element name="standard7"/>
		<xsl:element name="yellow"/>
		<!-- <xsl:value-of select="substring-after(@name,'::')" /> -->
		<xsl:call-template name="substring-before-last">
			<xsl:with-param name="input" select="@name"/>
			<xsl:with-param name="marker" select="' ::'"/>
		</xsl:call-template>
			<xsl:element name="mode">
		<xsl:attribute name="position">bottom</xsl:attribute>
		<xsl:attribute name="display">rotate</xsl:attribute>
		</xsl:element>
		
		<xsl:choose>
		<!-- <xsl:if test="contains(type,'A') or contains(type,'B')"> -->
			<xsl:when test="@lastBuildStatus='Failure'">
				<xsl:element name="fancy7"/>
				<xsl:text>Build: </xsl:text>
				<xsl:value-of select="@lastBuildLabel"/>
				<xsl:element name="red"/>
				<xsl:text> Failed!</xsl:text>
			</xsl:when>

			<xsl:when test="@lastBuildStatus='Exception'">
				<xsl:element name="red"/>
				<!-- <xsl:element name="fancy7"/> -->
				<xsl:text>Build: </xsl:text>
				<xsl:value-of select="@lastBuildLabel"/>
				<xsl:text> </xsl:text>
				<xsl:text> generated an Exeception.</xsl:text>
			</xsl:when>

			<xsl:when test="@lastBuildStatus='Unknown'">
				<xsl:element name="yellow"/>
				<xsl:element name="fancy7"/>
				<xsl:text>Build: </xsl:text>
				<xsl:value-of select="@lastBuildLabel"/>
				<xsl:text> </xsl:text>
				<xsl:text> last build status is unknown.</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:element name="green"/>
				<xsl:element name="fancy7"/>
				<xsl:text>Build: </xsl:text>
				<xsl:value-of select="@lastBuildLabel"/>
				<xsl:text> was successfully built.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- <xsl:text> @ </xsl:text>
		<xsl:value-of select="substring-after(@lastBuildTime,'T')"/> -->
		<xsl:text> </xsl:text>
	
		<xsl:choose>
			<xsl:when test="@activity='Building'">
				<xsl:element name="yellow"/>
				<xsl:element name="fancy7"/>
				<xsl:text>The Build is currently </xsl:text>
				<xsl:value-of select="@activity"/>
			</xsl:when>

			<xsl:when test="@activity='CheckingModifications'">
				<xsl:element name="yellow"/>
				<xsl:element name="fancy7"/>
				<xsl:text>The Build is currently </xsl:text>
				<xsl:value-of select="@activity"/>
			</xsl:when>

			<xsl:when test="@activity='Sleeping'">
				<xsl:element name="green"/>
				<xsl:element name="fancy7"/>
				<xsl:text>The Build is currently </xsl:text>
				<xsl:value-of select="@activity"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>

		</xsl:element>
		<xsl:element name="CR" />
	</xsl:template>
	
	<xsl:template name="substring-after-last">
		<xsl:param name="input"/>
		<xsl:param name="marker"/>
		<xsl:choose>
			<xsl:when test="contains($input,$marker)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="input" select="substring-after($input,$marker)"/>
					<xsl:with-param name="marker" select="$marker"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="substring-before-last">
		<xsl:param name="input"/>
		<xsl:param name="marker"/>
		<xsl:choose>
			<xsl:when test="contains($input,$marker)">
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="input" select="substring-before($input,$marker)"/>
					<xsl:with-param name="marker" select="$marker"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- dont want to use hardwired values -->

	<!-- <xsl:value-of select="document('')//b:buildLookup/b:buildLookup[@name = current()]/@value,$dd)"/> -->
	

<b:buildLookup>
		<b:build name="Sauron :: build" value="Build Phase"/>
		<b:build name="Sauron :: build :: package" value="Package"/>
		<b:build name="Sauron :: build :: metrics" value="Metrics"/>
		<b:build name="Sauron :: rpm" value="RPM Phase"/>
		<b:build name="Sauron :: rpm :: rpmbuild" value="05"/>
		<b:build name="Sauron :: cibuild" value="CI Build Phase"/>
		<b:build name="Sauron :: cibuild :: deploy-rpm-and-run-twist-scenarios" value="Deploy rpm run Twist"/>
		<b:build name="Sauron :: cibuild.integration.twist.tests" value="Int Twist Phase"/>
		<b:build name="Sauron :: cibuild.integration.twist.tests :: run-integration-twist-scenarios" value="09"/>
		<b:build name="Sauron :: qastubbed" value="QA Stubbed"/>
		<b:build name="Sauron :: qastubbed :: deploy.to.devapp019" value="devapp019"/>
		<b:build name="Sauron :: qastubbed :: deploy.to.devapp020" value="devapp020"/>
	  <b:build name="Sauron :: qarpm" value="QA RPM phase"/>
    <b:build name="Sauron :: qarpm :: rpmbuild_qa" value="Build QA RPM"/>
</b:buildLookup>

	<!-- name="Sauron :: build" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="2084" lastBuildTime=" -->
	
	
	<xsl:template match="/xml_api_reply/weather">
		<xsl:element name="alphasign">
			<xsl:element name="string">
				<xsl:attribute name="label"><xsl:value-of select="$text-label"/></xsl:attribute>
				
				<xsl:element name="msg">
					<xsl:text>Weather: </xsl:text>
					<!-- <xsl:value-of select="forecast_information/city/@data"/>
					<xsl:text>. </xsl:text> -->
				</xsl:element>
				<xsl:apply-templates select="current_conditions"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="/xml_api_reply/weather/current_conditions">
		
		<xsl:element name="msg">
			<xsl:value-of select="condition/@data"/>
	    <xsl:text>, </xsl:text>
			<xsl:value-of select="temp_c/@data"/>
			<xsl:element name="extendedChar">
			<xsl:attribute name="offset">49</xsl:attribute>
			</xsl:element>
			<xsl:text>C, </xsl:text>
			<xsl:value-of select="wind_condition/@data"/>
      <xsl:text>.</xsl:text>
      </xsl:element>
	</xsl:template>
</xsl:stylesheet>
