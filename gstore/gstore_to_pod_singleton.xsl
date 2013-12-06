<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="fn xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- project open data: single dataset json -->
    
    <!-- TODO: revise the date structure for actual UTC -->
    
    <xsl:variable name="all-contacts" select="/metadata/contacts"/>
    <xsl:variable name="all-citations" select="/metadata/citations"/>
    
    <xsl:template name="json-list">
        <xsl:param name="elements"/>
        <xsl:value-of>
            <xsl:for-each select="fn:tokenize($elements, ',')">"<xsl:sequence select="."/>"<xsl:if test="not(position() eq last())">,</xsl:if></xsl:for-each>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template name="parse-datetime">
        <xsl:param name="date-str" select="()"/>
        <xsl:param name="time-str" select="()"/>
        
        <xsl:choose>
            <xsl:when test="($date-str and $date-str != 'Unknown') and ($time-str and $time-str != 'Unknown')">
                <xsl:value-of select="fn:concat($date-str, 'T', fn:substring-before($time-str, '+'), 'Z')"/>
            </xsl:when>
            <xsl:when test="(not($date-str) or $date-str = 'Unknown')">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="fn:concat($date-str, 'T00:00:00Z')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="/metadata">
        
        <xsl:variable name="identity-citation-id" select="identification/citation[@role='identify']/@ref"/>
        <xsl:variable name="identity-citation" select="$all-citations/citation[@id=$identity-citation-id]"/>
        <xsl:variable name="keyword-list">
            <xsl:call-template name="json-list">
                <!-- unnecessary except for the double quotes -->
                <xsl:with-param name="elements" select="fn:string-join(identification/themes/theme/term/text(), ',')"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="date-modified">
            <!-- pulling from the main citation for now -->
            <xsl:variable name="single-str">
                <xsl:call-template name="parse-datetime">
                    <xsl:with-param name="date-str" select="$identity-citation/publication/pubdate/@date"/>
                    <xsl:with-param name="time-str" select="$identity-citation/publication/pubdate/@time"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$single-str"/>
        </xsl:variable>
        <xsl:variable name="temporal">
            <xsl:choose>
                <xsl:when test="fn:count(identification/time/single) = 1">
                    <xsl:variable name="single-str">
                        <xsl:call-template name="parse-datetime">
                            <xsl:with-param name="date-str" select="identification/time/single/@date"/>
                            <xsl:with-param name="time-str" select="identification/time/single/@time"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$single-str"/>
                </xsl:when>
                <xsl:when test="fn:count(identification/time/single) > 1">
                    <!-- NOTE: this assumes the dates are in order which is not a safe assumption but it's a start -->
                    <xsl:variable name="begin-str">
                        <xsl:call-template name="parse-datetime">
                            <xsl:with-param name="date-str" select="identification/time/single[1]/@date"/>
                            <xsl:with-param name="time-str" select="identification/time/single[1]/@time"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="end-str">
                        <xsl:call-template name="parse-datetime">
                            <xsl:with-param name="date-str" select="(identification/time/single)[last()]/@date"/>
                            <xsl:with-param name="time-str" select="(identification/time/single)[last()]/@time"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:value-of select="$begin-str[text() != ''] | $end-str[text() != '']" separator="/"/>
                </xsl:when>
                <xsl:when test="identification/time/range">
                    <xsl:variable name="begin-str">
                        <xsl:call-template name="parse-datetime">
                            <xsl:with-param name="date-str" select="identification/time/range/start/@date"/>
                            <xsl:with-param name="time-str" select="identification/time/range/start/@time"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="end-str">
                        <xsl:call-template name="parse-datetime">
                            <xsl:with-param name="date-str" select="identification/time/range/end/@date"/>
                            <xsl:with-param name="time-str" select="identification/time/range/end/@time"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:value-of select="$begin-str[text() != ''] | $end-str[text() != '']" separator="/"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="publisher-id" select="metadata/contact[@role='point-contact']/@ref"/>
        <xsl:variable name="publisher-contact" select="$all-contacts/contact[@id=$publisher-id]"/>
        <xsl:variable name="distribution-list">
            <xsl:for-each select="distribution/distributor/downloads/download">
                {
                "accessURL": "<xsl:value-of select="link"/>",
                "format": "<xsl:value-of select="type"/>"
                }<xsl:if test="not(position() eq last())">,</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- TODO: switch to the services.json response? starting with FGDC - at least it has all of the access URLs -->
        <xsl:variable name="service" select="$identity-citation/onlink[ends-with(text(), 'FGDC-STD-012-2002.xml')] | $identity-citation/onlink[ends-with(text(), 'FGDC-STD-001-1998.xml')]"/>       
{
    "title": "<xsl:value-of select="fn:normalize-space(identification/title)"/>",
    "description": "<xsl:value-of select="fn:normalize-space(identification/abstract)"/>",
    "keyword": [<xsl:value-of select="$keyword-list"/>],
    "modified": "<xsl:value-of select="$date-modified"/>",
    "publisher": "<xsl:value-of select="$publisher-contact/organization/name"/>",
    "contactPoint": "<xsl:value-of select="if ($publisher-contact/organization/person) then $publisher-contact/organization/person else $publisher-contact/position"/>",
    "mbox": "<xsl:value-of select="$publisher-contact/email"/>",
    "identifier": "<xsl:value-of select="identification/@identifier"/>",
    "accessLevel": "public",
    "accessLevelComment": "",
    "distribution": [<xsl:value-of select="$distribution-list"/>],
    "webService": "<xsl:value-of select="$service"/>",
    "license": "Public Domain",
    "spatial": "<xsl:value-of select="fn:normalize-space(spatial/indspref)"/>",
    "temporal": "<xsl:value-of select="$temporal"/>"
}
    </xsl:template>
    
</xsl:stylesheet>