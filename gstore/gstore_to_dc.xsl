<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="fn"
    >
    
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"></xsl:output>
    
    <xsl:variable name="all-citations" select="/metadata/citations"></xsl:variable>
    <xsl:variable name="all-contacts" select="/metadata/contacts"></xsl:variable>
    
    <xsl:template match="/metadata">
        <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
        <xsl:variable name="identity-citation" select="$all-citations/citation[@id=$identity-citation-id]"/>
        <xsl:variable name="metadata-contact-id" select="metadata/contact/@ref"/>
        <xsl:variable name="metadata-contact" select="$all-contacts/contact[@id=$metadata-contact-id]"></xsl:variable>
        
        <dc xmlns="info:srw/schema/1/dc-schema" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/resources/dc-schema.xsd">
            <dc:creator>
                <xsl:value-of select="$identity-citation/origin"></xsl:value-of>
            </dc:creator>
            <dc:subject>
                <xsl:value-of select="identification/themes/theme/term" separator=","></xsl:value-of>
            </dc:subject>
            <dc:description>
                <xsl:value-of select="identification/abstract"/>
            </dc:description>
            <dc:publisher>
                <xsl:value-of select="$metadata-contact/organization/name"></xsl:value-of>
            </dc:publisher>
            <dc:contributor>Your Name</dc:contributor>
            <dc:date>
                <xsl:value-of select="$identity-citation/publication/pubdate/@date"/>
            </dc:date>
            
            <xsl:variable name="first-distribution" select="distribution/distributor/downloads/download[1]"/>
            <dc:type>
                <xsl:value-of select="$first-distribution/type"/>
            </dc:type>
            <dc:format>
                <xsl:value-of select="$first-distribution/type"/>
            </dc:format>
            <dc:identifier>
                <xsl:value-of select="identification/@dataset"/>
            </dc:identifier>
            <dc:source>Can be left blank</dc:source>
            <dc:language>eng</dc:language>
            <dc:relation>None</dc:relation>
            <dc:coverage>
                <xsl:value-of select="fn:concat('North ', spatial/north)"/>, 
                <xsl:value-of select="fn:concat('South ', spatial/south)"/>, 
                <xsl:value-of select="fn:concat('East ', spatial/east)"/>, 
                <xsl:value-of select="fn:concat('West ', spatial/west)"/>, Global
            </dc:coverage>
            <dc:rights>CC</dc:rights>
            <!--<dct:modified>
                <xsl:value-of select="metadata/pubdate/@date"/>
            </dct:modified>-->
        </dc>
    </xsl:template>
    
</xsl:stylesheet>