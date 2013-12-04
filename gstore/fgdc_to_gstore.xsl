<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="fn xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:key name="unique-contacts-key" match="cntinfo" use="."></xsl:key>
    <xsl:key name="unique-citations-key" match="citeinfo" use="."></xsl:key>
    <xsl:key name="unique-sources-key" match="srcinfo" use="."></xsl:key>
    
    <xsl:template name="to-iso-date">
        <xsl:param name="datestr" select="()"/>
        <!-- convert fgdc date (yyyyMMdd) to iso date (yyyy-MM-dd) -->
        <xsl:choose>
            <xsl:when test="fn:contains(fn:lower-case($datestr), 'unknown')">
                <xsl:value-of select="'Unknown'"/>
            </xsl:when>
            <xsl:when test="fn:contains(fn:lower-case($datestr), 'unpublished')">
                <xsl:value-of select="'Unpublished'"/>
            </xsl:when>
            <xsl:when test="fn:contains(fn:lower-case($datestr), 'present')">
                <xsl:value-of select="'Present'"/>
            </xsl:when>
            <xsl:when test="fn:contains(fn:lower-case($datestr), 'not complete') or fn:contains(fn:lower-case($datestr), 'incomplete')">
                <xsl:value-of select="$datestr"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="year">
                    <xsl:value-of select="fn:substring($datestr, 1, 4)"/>
                </xsl:variable>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="fn:string-length($datestr) > 4">
                            <xsl:value-of select="fn:substring($datestr, 5, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="fn:string-length($datestr) > 6">
                            <xsl:value-of select="fn:substring($datestr, 7, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:value-of select="$year[text() != ''] | $month[text() != ''] | $day[text() != '']" separator="-"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template name="to-iso-time">
        <xsl:param name="timestr" select="()"/>
        <!-- convert fgdc time (hhmmss with +-0000 or Z) to iso time -->
        <xsl:choose>
            <xsl:when test="fn:contains(fn:lower-case($timestr), 'unknown')">
                <xsl:value-of select="'Unknown'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="hours">
                    <xsl:value-of select="fn:substring($timestr, 1, 2)"/>
                </xsl:variable>
                <xsl:variable name="minutes">
                    <xsl:value-of select="fn:substring($timestr, 3, 2)"/>
                </xsl:variable>
                <xsl:variable name="seconds">
                    <xsl:value-of select="fn:substring($timestr, 5, 2)"/>
                </xsl:variable>
                
                <xsl:variable name="new-time">
                    <xsl:value-of select="$hours[text() != ''] | $minutes[text() != ''] | $seconds[text() != '']" separator=":"></xsl:value-of>
                </xsl:variable>
                
                <xsl:variable name="offset">
                    <xsl:variable name="sign">
                        <xsl:choose>
                            <!-- as +0000 or -0000 -->
                            <xsl:when test="fn:contains($timestr, '+')">
                                <xsl:value-of select="'+'"></xsl:value-of>
                            </xsl:when>
                            <xsl:when test="fn:contains($timestr, '-')">
                                <xsl:value-of select="'-'"></xsl:value-of>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$sign">
                            <xsl:variable name="offstr" select="fn:substring-after($timestr, $sign)"/>
                            <xsl:variable name="off-hours" select="fn:substring($offstr, 1, 2)"/>
                            <xsl:variable name="off-minutes" select="fn:substring($offstr, 3, 2)"/>
                            <xsl:value-of select="fn:concat($sign, $off-hours, ':', $off-minutes)"></xsl:value-of>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="utc">
                    <xsl:choose>
                        <xsl:when test="fn:contains($timestr, 'Z')">
                            <xsl:value-of select="Z"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="()"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$utc">
                        <xsl:value-of select="fn:concat($new-time, $utc)"/>
                    </xsl:when>
                    <xsl:when test="$offset">
                        <xsl:value-of select="fn:concat($new-time, $offset)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$new-time"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="return-contact">
        <xsl:param name="contact-to-id" select="()"/>
        <xsl:param name="contacts"/>
        
        <xsl:variable name="contact-ids">
            <xsl:choose>
                <xsl:when test="$contact-to-id/cntinfo/cntpos">
                    <xsl:value-of select="$contacts/contact[cntinfo/cntpos=$contact-to-id/cntinfo/cntpos]/@id"></xsl:value-of>
                </xsl:when>
                <xsl:when test="$contact-to-id/cntinfo/cntorgp">
                    <xsl:value-of select="$contacts/contact[cntinfo/cntorgp/cntorg=$contact-to-id/cntinfo/cntorgp/cntorg]/@id"></xsl:value-of>
                </xsl:when>
                <xsl:when test="$contact-to-id/cntinfo/cntperp">
                    <xsl:value-of select="$contacts/contact[cntinfo/cntperp/cntper=$contact-to-id/cntinfo/cntperp/cntper]/@id"></xsl:value-of>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="contact-id">
            <xsl:choose>
                <xsl:when test="fn:count(fn:tokenize($contact-ids, ' ')) > 1">
                    <xsl:value-of select="fn:tokenize($contact-ids, ' ')[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$contact-ids"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="$contact-id"/>
    </xsl:template>
    
    <xsl:template match="/metadata">
<!--    generate the lists of unique contact, citation and source entries with unique ids    -->
        <xsl:variable name="unique-citations">
            <citations>
                <xsl:for-each select="//citeinfo[generate-id() = generate-id(key('unique-citations-key', .)[1])]">
                    <citation id="{generate-id()}">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </citation>
                </xsl:for-each>
            </citations>
        </xsl:variable>
        <xsl:variable name="unique-contacts">
            <contacts>
                <xsl:for-each select="//cntinfo[generate-id() = generate-id(key('unique-contacts-key', .)[1])]">
                    <contact id="{generate-id()}">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </contact>
                </xsl:for-each>
            </contacts>
        </xsl:variable>
        <xsl:variable name="unique-sources">
            <sources>
                <xsl:for-each select="//srcinfo[generate-id() = generate-id(key('unique-sources-key', .)[1])]">
                    <source id="{generate-id()}">
                        <xsl:attribute name="type" select="../local-name()"></xsl:attribute>
                        <xsl:copy-of select="."></xsl:copy-of>
                    </source>
                </xsl:for-each>
            </sources>
        </xsl:variable>
        
        <!-- now put it in the one variable with the sources updated with a citation -->
        <xsl:variable name="constants">
            <constants>
                <xsl:copy-of select="$unique-contacts"></xsl:copy-of>
                <xsl:copy-of select="$unique-citations"></xsl:copy-of>
                <sources>
                    <xsl:for-each select="$unique-sources/sources/source">
                        <source id="{generate-id()}" type="{@type}">
                            <xsl:for-each select="srcinfo/*">
                               <xsl:choose>
                                   <xsl:when test=".[local-name()='srccite']">
                                       <!--                                       -->
                                       <xsl:variable select=".[local-name()='srccite']" name="local-srcinfo"></xsl:variable>
                                      
                                       <xsl:variable name="src-cite-ids" select="$unique-citations/citations/citation[citeinfo=$local-srcinfo/citeinfo]/@id"></xsl:variable>
                                       <xsl:variable name="cite-id">
                                           <xsl:choose>
                                               <xsl:when test="fn:count($src-cite-ids) > 1">
                                                   <xsl:value-of select="$src-cite-ids[1]"/>
                                               </xsl:when>
                                               <xsl:otherwise>
                                                   <xsl:value-of select="$src-cite-ids"/>
                                               </xsl:otherwise>
                                           </xsl:choose>
                                       </xsl:variable>
                                       <citation ref="{$cite-id}"></citation> 
                                   </xsl:when> 
                                   <xsl:otherwise>
                                       <xsl:copy-of select="."></xsl:copy-of>
                                   </xsl:otherwise>
                               </xsl:choose>
                            </xsl:for-each>
                        </source>
                    </xsl:for-each>
                </sources>
            </constants>
        </xsl:variable>
        
        <metadata>
            <!-- TODO: add the xsi widget-->
            <!--<xsl:attribute name="schemaLocation" select="'http://129.24.63.115/xslts/gstore_schema.xsd'"></xsl:attribute>-->
<!--        hardcoded for testing DO SOMETHING!    -->
            <original>
                <standard version="{metainfo/metstdv}">
                    <title><xsl:value-of select="metainfo/metstdn"></xsl:value-of></title>
                </standard>  
                <!--<extension version="">
                    <title></title>
                    <url></url>
                </extension> --> 
                <xsl:if test="metainfo/metextns">
                    <profile>
                        <title><xsl:value-of select="metainfo/metextns/metprof"></xsl:value-of></title>
                        <url><xsl:value-of select="metainfo/metextns/onlink"></xsl:value-of></url>
                    </profile>
                </xsl:if>
                
            </original>
            
            <identification>
                <xsl:attribute name="identifier">
                    <xsl:choose>
                        <xsl:when test="idinfo/datsetid">
                            <xsl:value-of select="idinfo/datsetid"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="fn:tokenize(fn:substring-before(fn:base-uri(.), '.xml'), '/')[last()]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <title>
                    <xsl:value-of select="idinfo/citation/citeinfo/title"></xsl:value-of>
                </title>
                <abstract>
                    <xsl:value-of select="idinfo/descript/abstract"></xsl:value-of>
                </abstract>
                <purpose>
                    <xsl:value-of select="idinfo/descript/purpose"></xsl:value-of>
                </purpose>
                <xsl:if test="idinfo/descript/supplinf">
                    <supplinfo>
                        <xsl:value-of select="idinfo/descript/supplinf"></xsl:value-of>
                    </supplinfo>
                </xsl:if>
                
<!--            get the point of contact (which is fgdc optional, fyi)    -->
                <xsl:variable name="point-contact" select="idinfo/ptcontac"></xsl:variable>
                <xsl:variable name="contact-id">
                    <xsl:call-template name="return-contact">
                        <xsl:with-param name="contact-to-id" select="$point-contact"></xsl:with-param>
                        <xsl:with-param name="contacts" select="$constants/constants/contacts"></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$point-contact and $contact-id">
                    <contact role="point-contact" ref="{$contact-id}"></contact>
                </xsl:if>
                

<!--            and any citation chunks     -->
                <xsl:variable name="id-citation" select="idinfo/citation"></xsl:variable>
                <citation role="identify" ref="{$constants/constants/citations/citation[citeinfo/origin=$id-citation/citeinfo/origin and citeinfo/title=$id-citation/citeinfo/title][1]/@id}">
                    <xsl:if test="$id-citation/citeinfo/lworkcit">
                        <citation role="larger-work" ref="{$constants/constants/citations/citation[citeinfo/origin=$id-citation/citeinfo/lworkcit/citeinfo/origin and citeinfo/title=$id-citation/citeinfo/lworkcit/citeinfo/title][1]/@id}"></citation>
                    </xsl:if>
                </citation>

                <xsl:if test="idinfo/crossref">
                    <xsl:for-each select="idinfo/crossref">
                        <xsl:variable name="crossref" select="."></xsl:variable>
<!--                    TODO: fix for multiples    -->
                        <citation role="crossref" ref="{$constants/constants/citations/citation[citeinfo/origin=$crossref/citeinfo/origin and citeinfo/title=$crossref/citeinfo/title][1]/@id}"></citation>
                    </xsl:for-each>
                </xsl:if>

                <time>
                    <xsl:choose>
                        <xsl:when test="idinfo/timeperd/timeinfo/sngdate">
                            <single>
                                <xsl:variable name="iso-date">
                                    <xsl:call-template name="to-iso-date">
                                        <xsl:with-param name="datestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/sngdate/caldate)"></xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:attribute name="date" select="$iso-date"/>
                                <xsl:if test="idinfo/timeperd/timeinfo/sngdate/time">
                                    <xsl:variable name="iso-time">
                                        <xsl:call-template name="to-iso-time">
                                            <xsl:with-param name="timestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/sngdate/time)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="time" select="$iso-time"/>
                                </xsl:if>
                            </single>
                        </xsl:when>
                        <xsl:when test="idinfo/timeperd/timeinfo/rngdates">
                            <range>
                                <start>
                                    <xsl:variable name="iso-date">
                                        <xsl:call-template name="to-iso-date">
                                            <xsl:with-param name="datestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/rngdates/begdate)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="date" select="$iso-date"/>
                                    <xsl:if test="idinfo/timeperd/timeinfo/rngdates/begtime">
                                        <xsl:variable name="iso-time">
                                            <xsl:call-template name="to-iso-time">
                                                <xsl:with-param name="timestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/rngdates/begtime)"></xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:attribute name="time" select="$iso-time"/>
                                    </xsl:if>
                                </start>
                                <end>
                                    <xsl:variable name="iso-date">
                                        <xsl:call-template name="to-iso-date">
                                            <xsl:with-param name="datestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/rngdates/enddate)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="date" select="$iso-date"/>
                                    <xsl:if test="idinfo/timeperd/timeinfo/rngdates/endtime">
                                        <xsl:variable name="iso-time">
                                            <xsl:call-template name="to-iso-time">
                                                <xsl:with-param name="timestr" select="fn:normalize-space(idinfo/timeperd/timeinfo/rngdates/endtime)"></xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:attribute name="time" select="$iso-time"/>
                                    </xsl:if>
                                </end>
                            </range>
                        </xsl:when>
                        <xsl:when test="idinfo/timeperd/timeinfo/mdattim">
                            <xsl:for-each select="idinfo/timeperd/timeinfo/mdattim/sngdate">
                                <single>
                                    <xsl:variable name="iso-date">
                                        <xsl:call-template name="to-iso-date">
                                            <xsl:with-param name="datestr" select="fn:normalize-space(caldate)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="date" select="$iso-date"/>
   
                                    <xsl:if test="time">
                                        <xsl:variable name="iso-time">
                                            <xsl:call-template name="to-iso-time">
                                                <xsl:with-param name="timestr" select="fn:normalize-space(time)"></xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:attribute name="time" select="$iso-time"/>
                                    </xsl:if>
                                </single>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="idinfo/timeperd/current">
                        <current><xsl:value-of select="idinfo/timeperd/current"></xsl:value-of></current>
                    </xsl:if>
                </time>
                
                <xsl:if test="idinfo/keywords/theme[themekt='ISO 19115 Topic Categories']">
                    <isotopic>
                        <xsl:value-of select="idinfo/keywords/theme[themekt='ISO 19115 Topic Categories']/themekey"></xsl:value-of>
                    </isotopic>
                </xsl:if>
                
                <xsl:if test="idinfo/keywords/theme[themekt!='ISO 19115 Topic Categories']">
                   <themes>
                       <xsl:for-each select="idinfo/keywords/theme[themekt!='ISO 19115 Topic Categories']">
                           <theme thesaurus="{fn:normalize-space(themekt)}">
                               <xsl:for-each select="themekey">
                                   <term>
                                       <xsl:value-of select="."></xsl:value-of>
                                   </term>
                               </xsl:for-each>
                           </theme>
                       </xsl:for-each>
                   </themes>
                </xsl:if>
                <xsl:if test="idinfo/keywords/place">
                    <places>
                        <xsl:for-each select="idinfo/keywords/place">
                            <place thesaurus="{fn:normalize-space(placekt)}">
                                <xsl:for-each select="placekey">
                                    <term>
                                        <xsl:value-of select="."></xsl:value-of>
                                    </term>
                                </xsl:for-each>
                            </place>
                        </xsl:for-each>
                    </places>
                </xsl:if>
                <xsl:if test="idinfo/keywords/stratum">
                    <stratums>
                        <xsl:for-each select="idinfo/keywords/stratum">
                            <stratum thesaurus="{fn:normalize-space(stratkt)}">
                                <xsl:for-each select="stratkey">
                                    <term>
                                        <xsl:value-of select="."></xsl:value-of>
                                    </term>
                                </xsl:for-each>
                            </stratum>
                        </xsl:for-each>
                    </stratums>
                </xsl:if>
                <xsl:if test="idinfo/keywords/temporal">
                    <temporals>
                        <xsl:for-each select="idinfo/keywords/temporal">
                            <temporal thesaurus="{fn:normalize-space(tempkt)}">
                                <xsl:for-each select="tempkey">
                                    <term>
                                        <xsl:value-of select="."></xsl:value-of>
                                    </term>
                                </xsl:for-each>
                            </temporal>
                        </xsl:for-each>
                    </temporals>
                </xsl:if>
                
                <xsl:if test="idinfo/browse">
                    <browse>
                        <xsl:if test="idinfo/browse/browsen">
                            <filename>
                                <xsl:value-of select="idinfo/browse/browsen"></xsl:value-of>
                            </filename>
                        </xsl:if>
                        <xsl:if test="idinfo/browse/browsed">
                            <description>
                                <xsl:value-of select="idinfo/browse/browsed"></xsl:value-of>
                            </description>
                        </xsl:if>
                        <xsl:if test="idinfo/browse/browset">
                            <filetype>
                                <xsl:value-of select="idinfo/browse/browset"></xsl:value-of>
                            </filetype>
                        </xsl:if>
                    </browse>
                </xsl:if>
                
                <xsl:if test="idinfo/native">
                    <native>
                        <xsl:value-of select="idinfo/native"></xsl:value-of>
                    </native>
                </xsl:if>
                
                <xsl:if test="idinfo/datacred">
                    <credit><xsl:value-of select="idinfo/datacred"></xsl:value-of></credit>
                </xsl:if>
                
            </identification>
            <constraints>
                <xsl:if test="idinfo/accconst">
                    <access type="data">
                        <xsl:value-of select="idinfo/accconst"></xsl:value-of>
                    </access>
                </xsl:if>     
                <xsl:if test="idinfo/useconst">
                    <use type="data">
                        <xsl:value-of select="idinfo/useconst"></xsl:value-of>
                    </use>
                </xsl:if> 
                
                <xsl:if test="metainfo/metac">
                    <access type="metadata">
                        <xsl:value-of select="metainfo/metac"></xsl:value-of>
                    </access>
                </xsl:if>     
                <xsl:if test="metainfo/metuc">
                    <use type="metadata">
                        <xsl:value-of select="metainfo/metuc"></xsl:value-of>
                    </use>
                </xsl:if>
                
                <xsl:if test="idinfo/secinfo">
                    <security type="data">
                        <classification>
                            <xsl:if test="idinfo/secinfo/secsys">
                                <xsl:attribute name="system" select="idinfo/secinfo/secsys"></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="idinfo/secinfo/secclass"></xsl:value-of>
                        </classification>
                        <xsl:if test="idinfo/secinfo/sechandl">
                            <handling>
                                <xsl:value-of select="idinfo/secinfo/sechandl"></xsl:value-of>
                            </handling>
                        </xsl:if>
                    </security>
                </xsl:if>
                
                <xsl:if test="metainfo/metsi">
                    <security type="metadata">
                        <classification>
                            <xsl:if test="metainfo/metsi/metscs">
                                <xsl:attribute name="system" select="metainfo/metsi/metscs"></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="metainfo/metsi/metsc"></xsl:value-of>
                        </classification>
                        <xsl:if test="metainfo/metsi/metshd">
                            <handling>
                                <xsl:value-of select="metainfo/metsi/metshd"></xsl:value-of>
                            </handling>
                        </xsl:if>
                    </security>
                </xsl:if>
                
            </constraints>
            <spatial>
                <west>
                    <xsl:value-of select="idinfo/spdom/bounding/westbc"></xsl:value-of>
                </west>
                <east>
                    <xsl:value-of select="idinfo/spdom/bounding/eastbc"></xsl:value-of>
                </east>
                <south>
                    <xsl:value-of select="idinfo/spdom/bounding/southbc"></xsl:value-of>
                </south>
                <north>
                    <xsl:value-of select="idinfo/spdom/bounding/northbc"></xsl:value-of>
                </north>
            
                <indspref>
                    <xsl:choose>
                        <xsl:when test="spdoinfo/indspref">
                            <xsl:value-of select="normalize-space(spdoinfo/indspref)"></xsl:value-of>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Unknown'"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </indspref>
            
                <xsl:if test="spref">
                    <sprefs>
                     <xsl:if test="spref/horizsys/geodetic/horizdn">
                         <spref type="datum">
                             <xsl:variable name="datum-auth">
                                 <xsl:choose>
                                     <!-- wow. no. -->
                                     <xsl:when test="((contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '27')) 
                                         or ((contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '83')) 
                                         or spref/horizsys/geodetic/horizdn = 'D_Clarke_1866' 
                                         or (contains(spref/horizsys/geodetic/horizdn, 'Clarke_1866') and contains(spref/horizsys/geodetic/horizdn, 'Authalic')) 
                                         or spref/horizsys/geodetic/horizdn = 'D_WGS_1984' or spref/horizsys/geodetic/horizdn = 'D_North_American_1983_HARN'">
                                         <xsl:value-of select="'EPSG'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'EDAC'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable> 
                             <xsl:variable name="datum-code">
                                 <xsl:choose>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '27')">
                                         <xsl:value-of select="'4267'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '83')">
                                         <xsl:value-of select="'4269'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_Clarke_1866'">
                                         <xsl:value-of select="'7008'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="contains(spref/horizsys/geodetic/horizdn, 'Clarke_1866') and contains(spref/horizsys/geodetic/horizdn, 'Authalic')">
                                         <xsl:value-of select="'7052'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_WGS_1984'">
                                         <xsl:value-of select="'4326'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_North_American_1983_HARN'">
                                         <xsl:value-of select="'6152'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'Unknown'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="datum-url">
                                 <xsl:choose>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '27')">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4267'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/horizdn, 'North American Datum') or contains(spref/horizsys/geodetic/horizdn, 'NAD') or contains(spref/horizsys/geodetic/horizdn, 'D North American')) and contains(spref/horizsys/geodetic/horizdn, '83')">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4269'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_Clarke_1866'">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::7008'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="contains(spref/horizsys/geodetic/horizdn, 'Clarke_1866') and contains(spref/horizsys/geodetic/horizdn, 'Authalic')">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::7052'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_WGS_1984'">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4326'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/horizdn = 'D_North_American_1983_HARN'">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::6152'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'http://gstore.unm.edu'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             
                             <code><xsl:value-of select="$datum-code"></xsl:value-of></code>
                             <authority><xsl:value-of select="$datum-auth"></xsl:value-of></authority>
                             <onlineref><xsl:value-of select="$datum-url"></xsl:value-of></onlineref>
                             <title><xsl:value-of select="spref/horizsys/geodetic/horizdn"/></title>
                         </spref>
                     </xsl:if>
                     <xsl:if test="spref/horizsys/geodetic/ellips">
                         <spref type="ellipsoid">
                             <xsl:variable name="ellipsoid-auth" select="'EPSG'"></xsl:variable>
                             <xsl:variable name="ellipsoid-code">
                                 <xsl:choose>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/ellips, 'Geodetic Reference System') or contains(spref/horizsys/geodetic/ellips, 'GRS')) and contains(spref/horizsys/geodetic/ellips, '80')">
                                         <xsl:value-of select="'7019'"/>
                                     </xsl:when>
                                     <xsl:when test="contains(spref/horizsys/geodetic/ellips, 'Clarke') and contains(spref/horizsys/geodetic/ellips, '1866') and not(contains(spref/horizsys/geodetic/ellips, 'Authalic'))">
                                         <xsl:value-of select="'7008'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/ellips = 'Sphere_Clarke_1866_Authalic'">
                                         <xsl:value-of select="'7052'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/ellips, 'WGS') or contains(spref/horizsys/geodetic/ellips, 'World Geodetic System')) and contains(spref/horizsys/geodetic/ellips, '84')">
                                         <xsl:value-of select="'4326'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'Unknown'"/>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="ellipsoid-url">
                                 <xsl:choose>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/ellips, 'Geodetic Reference System') or contains(spref/horizsys/geodetic/ellips, 'GRS')) and contains(spref/horizsys/geodetic/ellips, '80')">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:ellipsoid:EPSG::7019'"/>
                                     </xsl:when>
                                     <xsl:when test="contains(spref/horizsys/geodetic/ellips, 'Clarke') and contains(spref/horizsys/geodetic/ellips, '1866') and not(contains(spref/horizsys/geodetic/ellips, 'Authalic'))">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:ellipsoid:EPSG::7008'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/geodetic/ellips = 'Sphere_Clarke_1866_Authalic'">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:ellipsoid:EPSG::7052'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="(contains(spref/horizsys/geodetic/ellips, 'WGS') or contains(spref/horizsys/geodetic/ellips, 'World Geodetic System')) and contains(spref/horizsys/geodetic/ellips, '84')">
                                         <xsl:value-of select="'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4326'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'Unknown'"/>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <code><xsl:value-of select="$ellipsoid-code"/></code>
                             <authority><xsl:value-of select="$ellipsoid-auth"/></authority>
                             <onlineref><xsl:value-of select="$ellipsoid-url"/></onlineref>
                             <title><xsl:value-of select="spref/horizsys/geodetic/ellips"/></title>
                         </spref>
                     </xsl:if>
                     <xsl:if test="spref/horizsys/planar/gridsys">
                         <spref type="gridsys">
                             
                             <xsl:variable name="grid-name">
                                 <xsl:value-of select="spref/horizsys/planar/gridsys/gridsysn"/>
                             </xsl:variable>
                             <xsl:variable name="grid-zone">
                                 <xsl:choose>
                                     <xsl:when test="spref/horizsys/planar/gridsys/utm">
                                         <xsl:value-of select="spref/horizsys/planar/gridsys/utm/utmzone"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="spref/horizsys/planar/gridsys/spcs">
                                         <xsl:value-of select="spref/horizsys/planar/gridsys/spcs/spcszone"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'-9999'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="grid-datum">
                                 <xsl:value-of select="spref/horizsys/geodetic/horizdn"></xsl:value-of>
                             </xsl:variable>
                             
                             <xsl:variable name="grid-auth">
                                 <xsl:choose>
                                     <xsl:when test="contains($grid-name, 'State Plane')">
                                         <xsl:value-of select="'ESRI'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'EPSG'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="grid-code">
                                 <xsl:choose>
                                     <xsl:when test="contains($grid-name, 'State Plane')">
                                         <xsl:choose>
                                             <xsl:when test="$grid-zone='3002'">
                                                 <xsl:value-of select="'102713'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone='3003'">
                                                 <xsl:value-of select="'102714'"/>
                                             </xsl:when>
                                         </xsl:choose>
                                     </xsl:when>
                                     <xsl:when test="contains($grid-name, 'Universal Transverse Mercator') or contains($grid-name, 'UTM')">
                                         <xsl:choose>
                                             <xsl:when test="$grid-zone=11 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '27'))">
                                                 <xsl:value-of select="'26711'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=11 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '83'))">
                                                 <xsl:value-of select="'26911'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=12 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '27'))">
                                                 <xsl:value-of select="'26712'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=12 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '83'))">
                                                 <xsl:value-of select="'26912'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=13 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '27'))">
                                                 <xsl:value-of select="'26713'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=13 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '83'))">
                                                 <xsl:value-of select="'26913'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=15 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '27'))">
                                                 <xsl:value-of select="'26715'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=15 and (contains($grid-datum, 'North American') or contains($grid-datum, 'NAD') and contains($grid-datum, '83'))">
                                                 <xsl:value-of select="'26915'"/>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=13 and (contains($grid-datum, 'WGS') and contains($grid-datum, '84'))">
                                                 <xsl:value-of select="'32613'"></xsl:value-of>
                                             </xsl:when>
                                             <xsl:when test="$grid-zone=12 and (contains($grid-datum, 'WGS') and contains($grid-datum, '84'))">
                                                 <xsl:value-of select="'32612'"></xsl:value-of>
                                             </xsl:when>
                                         </xsl:choose>
                                     </xsl:when>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="grid-url">
                                 <xsl:choose>
                                     <xsl:when test="$grid-auth='ESRI'">
                                         <xsl:value-of select="concat('http://spatialreference.org/ref/esri/', $grid-code, '/')"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="concat('http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::', $grid-code)"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <code><xsl:value-of select="$grid-code"/></code>
                             <authority><xsl:value-of select="$grid-auth"/></authority>
                             <onlineref><xsl:value-of select="$grid-url"/></onlineref>
                             <title><xsl:value-of select="fn:concat($grid-name, ', ', $grid-zone)"/></title>
                         </spref>
                     </xsl:if>
                     <xsl:if test="spref/horizsys/planar/mapproj">
                         <spref type="mapproj">
                             <xsl:variable name="proj-name">
                                 <xsl:value-of select="spref/horizsys/planar/mapproj/mapprojn"/>
                             </xsl:variable>
                             <xsl:variable name="proj-datum">
                                 <xsl:value-of select="spref/horizsys/geodetic/horizdn"/>
                             </xsl:variable>
                             
                             <xsl:variable name="proj-auth">
                                 <xsl:choose>
                                     <xsl:when test="contains($proj-name, 'Lambert Conformal Conic')">
                                         <xsl:value-of select="'ESRI'"/>
                                     </xsl:when>
                                     <xsl:when test="$proj-name = 'Transverse Mercator'">
                                         <xsl:value-of select="'EDAC'"/>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'EPSG'"/>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="proj-code">
                                 <xsl:choose>
                                     <xsl:when test="$proj-name='NAD 1983 UTM Zone 13N'">
                                         <xsl:value-of select="'26913'"/>
                                     </xsl:when>
                                     <xsl:when test="$proj-datum='D_North_American_1983_HARN' and contains($proj-name, 'Transverse Mercator')">
                                         <xsl:value-of select="'2903'"/>
                                     </xsl:when>
                                     <xsl:when test="$proj-name='Lambert Conform.al Conic' and contains($proj-datum, '83')">
                                         <xsl:value-of select="'102004'"/>
                                     </xsl:when>
                                     <xsl:when test="contains($proj-name, 'Lambert Azimuthal Equal Area') and contains($proj-datum, 'D_Sphere_Clarke_1866_Authalic')">
                                         <xsl:value-of select="'2163'"/>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'Unknown'"/>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="proj-url">
                                 <xsl:choose>
                                     <xsl:when test="$proj-auth='ESRI'">
                                         <xsl:value-of select="concat('http://spatialreference.org/ref/esri/', $proj-code, '/')"/>
                                     </xsl:when>
                                     <xsl:when test="$proj-code='Unknown'">
                                         <!-- TODO: change this to a real thing -->
                                         <xsl:value-of select="'http://gstore.unm.edu/sprefs/EDAC-Unknown'"/>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="concat('http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::', $proj-code)"/>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <code><xsl:value-of select="$proj-code"/></code>
                             <authority><xsl:value-of select="$proj-auth"/></authority>
                             <onlineref><xsl:value-of select="$proj-url"/></onlineref>
                             <title><xsl:value-of select="$proj-name"/></title>
                         </spref>
                     </xsl:if>
                     <xsl:if test="spref/vertdef/altsys">
                         <spref type="vertdef">
                             <xsl:variable name="vert-name" select="spref/vertdef/altsys/altdatum"></xsl:variable>
                             <xsl:variable name="vert-code">
                                 <xsl:choose>
                                     <xsl:when test="(contains($vert-name, 'North American Vertical Datum') or contains($vert-name, 'NAVD 88')) and contains($vert-name, '1988')">
                                         <xsl:value-of select="'5103'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:when test="contains($vert-name, 'National Geodetic Vertical Datum') or contains($vert-name, '1929')">
                                         <xsl:value-of select="'5102'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'Unknown'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="vert-auth">
                                 <xsl:choose>
                                     <xsl:when test="((contains($vert-name, 'North American Vertical Datum') or contains($vert-name, 'NAVD 88')) and contains($vert-name, '1988')) or (contains($vert-name, 'National Geodetic Vertical Datum') or contains($vert-name, '1929'))">
                                         <xsl:value-of select="'EPSG'"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'EDAC'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:variable name="vert-url">
                                 <xsl:choose>
                                     <xsl:when test="((contains($vert-name, 'North American Vertical Datum') or contains($vert-name, 'NAVD 88')) and contains($vert-name, '1988')) or (contains($vert-name, 'National Geodetic Vertical Datum') or contains($vert-name, '1929'))">
                                         <xsl:value-of select="fn:concat('http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:datum:EPSG::', $vert-code)"></xsl:value-of>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:value-of select="'http://gstore.unm.edu/spref/EDAC-Unknown'"></xsl:value-of>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             
                             <code><xsl:value-of select="$vert-code"/></code>
                             <authority><xsl:value-of select="$vert-auth"/></authority>
                             <onlineref><xsl:value-of select="$vert-url"/></onlineref>
                             <title><xsl:value-of select="$vert-name"/></title>
                         </spref>
                     </xsl:if>
                 </sprefs>
                </xsl:if>
                
                <!-- TODO: add the representation/@type=fgdc element and move the rights bits over -->
 
                <xsl:choose>
                    <xsl:when test="spdoinfo/direct[text()='Raster'] and spdoinfo/rastinfo">
                        <raster type="{spdoinfo/rastinfo/rasttype}" cval="{if (spdoinfo/rastinfo/cvaltype) then spdoinfo/rastinfo/cvaltype else 'Unknown'}">
                            <rows>
                                <xsl:value-of select="spdoinfo/rastinfo/rowcount"></xsl:value-of>
                            </rows>
                            <columns>
                                <xsl:value-of select="spdoinfo/rastinfo/colcount"></xsl:value-of>
                            </columns>
                            <xsl:if test="spdoinfo/rastinfo/vrtcount">
                               <verticals>
                                   <xsl:value-of select="spdoinfo/rastinfo/vrtcount"></xsl:value-of>
                               </verticals>
                            </xsl:if>
                        </raster>
                    </xsl:when>
                    <xsl:when test="spdoinfo/direct[text()='Vector'] and fn:count(spdoinfo/ptvctinf) > 0">
                        <vector>
                            <xsl:for-each select="spdoinfo/ptvctinf/sdtsterm">
                                <xsl:variable name="feature-count">
                                    <xsl:choose>
                                        <xsl:when test="ptvctcnt">
                                            <xsl:value-of select="fn:normalize-space(ptvctcnt)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'Unknown'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <sdts type="{fn:normalize-space(sdtstype)}" features="{$feature-count}"></sdts>
                            </xsl:for-each>
                        </vector>
                    </xsl:when>
                </xsl:choose>
            </spatial>
            <quality>
                <progress>
                    <xsl:value-of select="idinfo/status/progress"></xsl:value-of>
                </progress>
                <update>
                    <xsl:value-of select="idinfo/status/update"></xsl:value-of>
                </update>
                
                <xsl:if test="dataqual/logic">
                    <logical>
                         <xsl:value-of select="dataqual/logic"></xsl:value-of>
                    </logical>
                </xsl:if>
                <xsl:if test="dataqual/complete">
                    <completeness>
                        <xsl:value-of select="dataqual/complete"></xsl:value-of>
                    </completeness>
                </xsl:if>
                
                <xsl:if test="dataqual/attracc">
                    <qual type="attribute">
                        <report>
                            <xsl:value-of select="dataqual/attracc/attraccr"></xsl:value-of>
                        </report>
                        <xsl:if test="dataqual/attracc/qattracc">
                            <xsl:for-each select="dataqual/attracc/qattracc">
                                <quantitative>
                                    <value>
                                        <xsl:value-of select="attraccv"></xsl:value-of>
                                    </value>
                                    <explanation>
                                        <xsl:value-of select="attracce"></xsl:value-of>
                                    </explanation>
                                </quantitative>
                            </xsl:for-each>
                        </xsl:if>
                    </qual>
                </xsl:if>
                <xsl:if test="dataqual/posacc/horizpa">
                    <qual type="horizontal">
                        <report>
                            <xsl:value-of select="dataqual/posacc/horizpa/horizpar"></xsl:value-of>
                        </report>
                        <xsl:if test="dataqual/posacc/horizpa/qhorizpa">
                            <xsl:for-each select="dataqual/posacc/horizpa/qhorizpa">
                                <quantitative>
                                    <value>
                                        <xsl:value-of select="horizpav"></xsl:value-of>
                                    </value>
                                    <explanation>
                                        <xsl:value-of select="horizpae"></xsl:value-of>
                                    </explanation>
                                </quantitative>
                            </xsl:for-each>
                        </xsl:if>
                    </qual>
                </xsl:if>
                <xsl:if test="dataqual/posacc/vertacc">
                    <qual type="vertical">
                        <report>
                            <xsl:value-of select="dataqual/posacc/vertacc/vertaccr"></xsl:value-of>
                        </report>
                        <xsl:if test="dataqual/posacc/vertacc/qvertpa">
                            <xsl:for-each select="dataqual/posacc/vertacc/qvertpa">
                                <quantitative>
                                    <value>
                                        <xsl:value-of select="vertaccv"></xsl:value-of>
                                    </value>
                                    <explanation>
                                        <xsl:value-of select="vertacce"></xsl:value-of>
                                    </explanation>
                                </quantitative>
                            </xsl:for-each>
                        </xsl:if>
                    </qual>
                </xsl:if>
                
                <xsl:if test="dataqual/cloud">
                    <cloud>
                        <!--                        TODO: put something here    -->
                        <xsl:attribute name="ref" select="'Unknown'"/>
                        <xsl:value-of select="dataqual/cloud"></xsl:value-of>
                    </cloud>
                </xsl:if>
            </quality>
            <xsl:if test="dataqual/lineage/procstep">
                <lineage>
                    <xsl:for-each select="dataqual/lineage/procstep">
                        <step id="{position()}">
                            <description>
                                <xsl:value-of select="procdesc"></xsl:value-of>
                            </description>
                            <rundate>
                                <xsl:if test="procdate">
                                    <xsl:variable name="iso-date">
                                        <xsl:call-template name="to-iso-date">
                                            <xsl:with-param name="datestr" select="fn:normalize-space(procdate)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="date" select="$iso-date"/>
                                </xsl:if>
                                <xsl:if test="proctime">
                                    <xsl:variable name="iso-time">
                                        <xsl:call-template name="to-iso-time">
                                            <xsl:with-param name="timestr" select="fn:normalize-space(proctime)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="time" select="$iso-time"/>
                                </xsl:if>
                            </rundate>
                            
                            <xsl:if test="proccont">
                                <xsl:variable name="proc-contact" select="proccont"></xsl:variable>
                                
                                <xsl:variable name="contact-id">
                                    <xsl:call-template name="return-contact">
                                        <xsl:with-param name="contact-to-id" select="$proc-contact"/>
                                        <xsl:with-param name="contacts" select="$constants/constants/contacts"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <contact role="responsible-party" ref="{$contact-id}"/>
                            </xsl:if>
                            
                            <xsl:if test="srcused">
                                <xsl:for-each select="srcused">
                                    <xsl:variable name="src-used" select="fn:normalize-space(.)"/>
                                    <xsl:variable name="step-src" select="$constants/constants/sources/source[srccitea=$src-used]/@id"/>
                                    <xsl:variable name="step-src-id">
                                        <xsl:choose>
                                            <xsl:when test="fn:count($step-src) > 1">
                                                <xsl:value-of select="$step-src[1]"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$step-src"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:if test="$step-src">
                                        <source ref="{$step-src-id}" type="used"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:if test="srcprod">
                                <xsl:for-each select="srcprod">
                                    <xsl:variable name="src-prod" select="fn:normalize-space(.)"/>
                                    <xsl:variable name="step-src" select="$constants/constants/sources/source[srccitea=$src-prod]/@id"/>
                                    <xsl:variable name="step-src-id">
                                        <xsl:choose>
                                            <xsl:when test="fn:count($step-src) > 1">
                                                <xsl:value-of select="$step-src[1]"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$step-src"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:if test="$step-src">
                                        <source ref="{$step-src-id}" type="prod"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                        </step>
                    </xsl:for-each>
                </lineage>
            </xsl:if>
            
<!--        eainfo section    -->
            <xsl:choose>
                <xsl:when test="fn:exists(eainfo)">
                    <attributes>
                        <xsl:if test="eainfo/overview/eaover">
                            <overview>
                                <xsl:value-of select="eainfo/overview/eaover"></xsl:value-of>
                            </overview>
                        </xsl:if>
                        <xsl:if test="eainfo/overview/eadetcit">
                            <eacite>
                                <xsl:value-of select="eainfo/overview/eadetcit"></xsl:value-of>
                            </eacite>
                        </xsl:if>
                        
                        <xsl:if test="eainfo/detailed/enttyp">
                            <xsl:for-each select="eainfo/detailed/enttyp">
                                <entity>
                                    <xsl:if test="enttypl">
                                        <label>
                                            <xsl:value-of select="enttypl"></xsl:value-of>
                                        </label>
                                    </xsl:if>
                                    <xsl:if test="enttypd">
                                        <description>
                                            <xsl:value-of select="enttypd"></xsl:value-of>
                                        </description>
                                    </xsl:if>
                                    <xsl:if test="enttypds">
                                        <source>
                                            <xsl:value-of select="enttypds"></xsl:value-of>
                                        </source>
                                    </xsl:if>
                                </entity>
                            </xsl:for-each>
                        </xsl:if>
                   
                        <xsl:if test="eainfo/detailed/attr">
                            <xsl:for-each select="eainfo/detailed/attr">
                                <attr>
                                    <label>
                                        <xsl:value-of select="attrlabl"></xsl:value-of>
                                    </label>
                                    <definition>
                                        <xsl:value-of select="attrdef"></xsl:value-of>
                                    </definition>
                                    <source>
                                        <xsl:value-of select="attrdefs"></xsl:value-of>
                                    </source>
                                    
                                    <!-- element by type for easier validation -->
                                    <xsl:choose>
                                        <xsl:when test="attrdomv/udom">
                                            <unrepresented>
                                                <description>
                                                    <xsl:value-of select="attrdomv/udom"></xsl:value-of>
                                                </description>
                                            </unrepresented>
                                        </xsl:when>
                                        <xsl:when test="attrdomv/rdom">
                                            <range>
                                                <max>
                                                    <xsl:value-of select="attrdomv/rdom/rdommax"></xsl:value-of>
                                                </max>
                                                <min>
                                                    <xsl:value-of select="attrdomv/rdom/rdommin"></xsl:value-of>
                                                </min>
                                                <xsl:if test="attrdomv/rdom/attrunit">
                                                    <units>
                                                        <xsl:value-of select="attrdomv/rdom/attrunit"></xsl:value-of>
                                                    </units>
                                                </xsl:if>
                                            </range>
                                        </xsl:when>
                                        <xsl:when test="attrdomv/codesetd">
                                            <codeset>
                                                <name>
                                                    <xsl:value-of select="attrdomv/codesetd/codesetn"></xsl:value-of>
                                                </name>
                                                <source>
                                                    <xsl:value-of select="attrdomv/codesetd/codesets"></xsl:value-of>
                                                </source>
                                            </codeset>
                                        </xsl:when>
                                        <xsl:when test="attrdomv/edom">
                                            <enumerated>
                                                <xsl:for-each select="attrdomv/edom">
                                                    <value>
                                                        <enum>
                                                            <xsl:value-of select="edomv"></xsl:value-of>
                                                        </enum>
                                                        <description>
                                                            <xsl:value-of select="edomvd"></xsl:value-of>
                                                        </description>
                                                        <source>
                                                            <xsl:value-of select="edomvds"></xsl:value-of>
                                                        </source>
                                                    </value>
                                                </xsl:for-each>
                                            </enumerated>
                                        </xsl:when>
                                    </xsl:choose>
                                </attr>
                            </xsl:for-each>
                        </xsl:if>
                    
                    </attributes>
                </xsl:when>
            </xsl:choose>
            <metadata>
                <xsl:if test="metainfo/metc">
                    <xsl:variable name="meta-contact" select="metainfo/metc"></xsl:variable>
                    <xsl:variable name="contact-id">
                        <xsl:call-template name="return-contact">
                            <xsl:with-param name="contact-to-id" select="$meta-contact"></xsl:with-param>
                            <xsl:with-param name="contacts" select="$constants/constants/contacts"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <contact role="point-contact" ref="{$contact-id}"></contact>
                </xsl:if>
                <pubdate>
                    <xsl:variable name="iso-date">
                        <xsl:call-template name="to-iso-date">
                            <xsl:with-param name="datestr" select="fn:normalize-space(metainfo/metd)"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="date" select="$iso-date"/>
                </pubdate>
            </metadata>
<!--        move the constant nodes from the variable to the output and with the flatter structure    -->
            <contacts>
                <xsl:for-each select="$constants/constants/contacts/contact">
                    <contact id="{@id}">
                        <xsl:if test="cntinfo/cntpos">
                            <position><xsl:value-of select="cntinfo/cntpos"></xsl:value-of></position>
                        </xsl:if>
                       <xsl:if test="cntinfo/cntorgp">
                           <organization>
                               <name><xsl:value-of select="cntinfo/cntorgp/cntorg"></xsl:value-of></name>
                               <xsl:if test="cntinfo/cntorgp/cntper">
                                   <person><xsl:value-of select="cntinfo/cntorgp/cntper"></xsl:value-of></person>
                               </xsl:if>
                           </organization>
                       </xsl:if>  
                       <xsl:if test="cntinfo/cntperp">
                           <person>
                               <xsl:if test="cntinfo/cntperp/cntorg">
                                   <organization><xsl:value-of select="cntinfo/cntperp/cntorg"></xsl:value-of></organization>
                               </xsl:if>
                               
                               <name><xsl:value-of select="cntinfo/cntperp/cntper"></xsl:value-of></name>
                           </person>
                       </xsl:if>
                       <xsl:for-each select="cntinfo/cntaddr">
                           <address type="{addrtype}">
                               <xsl:for-each select="address">
                                   <addr><xsl:value-of select="."></xsl:value-of></addr>
                               </xsl:for-each>
                               <xsl:if test="city">
                                   <city><xsl:value-of select="city"></xsl:value-of></city>
                               </xsl:if>
                               
                               <xsl:if test="state">
                                   <state><xsl:value-of select="state"></xsl:value-of></state>
                               </xsl:if>
                               
                               <xsl:if test="postal">
                                   <postal><xsl:value-of select="postal"></xsl:value-of></postal>
                               </xsl:if>
                               
                               <xsl:if test="country">
                                   <country><xsl:value-of select="country"></xsl:value-of></country>
                               </xsl:if>
                           </address>
                       </xsl:for-each>
                       <voice><xsl:value-of select="cntinfo/cntvoice"></xsl:value-of></voice>
                        <xsl:if test="cntinfo/cntfax">
                            <fax><xsl:value-of select="cntinfo/cntfax"></xsl:value-of></fax>
                        </xsl:if>
                        <xsl:if test="cntinfo/cntemail">
                            <email><xsl:value-of select="cntinfo/cntemail"></xsl:value-of></email>
                        </xsl:if>
                       <xsl:if test="cntinfo/hours">
                           <hours><xsl:value-of select="cntinfo/hours"></xsl:value-of></hours>
                       </xsl:if>
                       <xsl:if test="cntinfo/cntinst">
                           <instructions><xsl:value-of select="cntinfo/cntinst"></xsl:value-of></instructions>
                        </xsl:if>
                    </contact>
                </xsl:for-each>
            </contacts>
            <citations>
                <xsl:for-each select="$constants/constants/citations/citation">
                    <citation id="{@id}">
                        <title><xsl:value-of select="citeinfo/title"></xsl:value-of></title>
                        <origin><xsl:value-of select="citeinfo/origin"></xsl:value-of></origin>
                        <xsl:if test="citeinfo/geoform">
                            <geoform><xsl:value-of select="citeinfo/geoform"></xsl:value-of></geoform>
                        </xsl:if>
                        <publication>
                            <pubdate>
                                <xsl:variable name="iso-date">
                                    <xsl:call-template name="to-iso-date">
                                        <xsl:with-param name="datestr" select="fn:normalize-space(citeinfo/pubdate)"></xsl:with-param>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:attribute name="date" select="$iso-date"/>
                                <xsl:if test="pubtime">
                                    <xsl:variable name="iso-time">
                                        <xsl:call-template name="to-iso-time">
                                            <xsl:with-param name="timestr" select="fn:normalize-space(citeinfo/pubtime)"></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:attribute name="time" select="$iso-time"/>
                                </xsl:if>
                            </pubdate>
                            <xsl:if test="citeinfo/pubinfo/pubplace">
                                <place>
                                    <xsl:value-of select="citeinfo/pubinfo/pubplace"></xsl:value-of>
                                </place>
                            </xsl:if>
                            <xsl:if test="citeinfo/pubinfo/publish">
                                <publisher>
                                    <xsl:value-of select="citeinfo/pubinfo/publish"></xsl:value-of>
                                </publisher>
                            </xsl:if>
                        </publication>
                        <xsl:if test="citeinfo/serinfo">
                            <serial>
                                <xsl:if test="citeinfo/serinfo/sername">
                                    <name><xsl:value-of select="citeinfo/serinfo/sername"></xsl:value-of></name>
                                </xsl:if>
                                <xsl:if test="citeinfo/serinfo/issue">
                                    <issue><xsl:value-of select="citeinfo/serinfo/issue"></xsl:value-of></issue>
                                </xsl:if>
                            </serial>
                        </xsl:if>
                        <xsl:if test="citeinfo/edition">
                            <edition><xsl:value-of select="citeinfo/edition"></xsl:value-of></edition>
                        </xsl:if>
                        <xsl:if test="citeinfo/othercit">
                            <othercit><xsl:value-of select="citeinfo/othercit"></xsl:value-of></othercit>
                        </xsl:if>
                        <xsl:for-each select="citeinfo/onlink">
                            <onlink><xsl:value-of select="."></xsl:value-of></onlink>
                        </xsl:for-each>
                    </citation>
                </xsl:for-each>
            </citations>
            <xsl:if test="$constants/constants/sources/source">
             <sources>
                 <xsl:for-each select="$constants/constants/sources/source">
                     <source id="{@id}" type="{@type}">
                         <xsl:if test="typesrc">
                             <type><xsl:value-of select="typesrc"></xsl:value-of></type>
                         </xsl:if>
                         <xsl:if test="srccitea">
                             <alias><xsl:value-of select="srccitea"></xsl:value-of></alias>
                         </xsl:if>
                         <xsl:if test="srcscale">
                             <scale><xsl:value-of select="srcscale"></xsl:value-of></scale>
                         </xsl:if>
                         <xsl:if test="srccontr">
                             <contribution><xsl:value-of select="srccontr"></xsl:value-of></contribution>
                         </xsl:if>
                         <xsl:if test="srctime">
                             <current><xsl:value-of select="srctime/srccurr"></xsl:value-of></current>
                             <srcdate>
                                 <xsl:choose>
                                     <xsl:when test="srctime/timeinfo/rngdates">
                                         <range>
                                             <start>
                                                 <xsl:variable name="iso-date">
                                                     <xsl:call-template name="to-iso-date">
                                                         <xsl:with-param name="datestr" select="fn:normalize-space(srctime/timeinfo/rngdates/begdate)"></xsl:with-param>
                                                     </xsl:call-template>
                                                 </xsl:variable>
                                                 <xsl:attribute name="date" select="$iso-date"/>
                                                 <xsl:if test="srctime/timeinfo/rngdates/begtime">
                                                     <xsl:variable name="iso-time">
                                                         <xsl:call-template name="to-iso-time">
                                                             <xsl:with-param name="timestr" select="fn:normalize-space(srctime/timeinfo/rngdates/begtime)"></xsl:with-param>
                                                         </xsl:call-template>
                                                     </xsl:variable>
                                                     <xsl:attribute name="time" select="$iso-time"/>
                                                 </xsl:if>
                                             </start>
                                             <end>
                                                 <xsl:variable name="iso-date">
                                                     <xsl:call-template name="to-iso-date">
                                                         <xsl:with-param name="datestr" select="fn:normalize-space(srctime/timeinfo/rngdates/enddate)"></xsl:with-param>
                                                     </xsl:call-template>
                                                 </xsl:variable>
                                                 <xsl:attribute name="date" select="$iso-date"/>
                                                 <xsl:if test="srctime/timeinfo/rngdates/endtime">
                                                     <xsl:variable name="iso-time">
                                                         <xsl:call-template name="to-iso-time">
                                                             <xsl:with-param name="timestr" select="fn:normalize-space(srctime/timeinfo/rngdates/endtime)"></xsl:with-param>
                                                         </xsl:call-template>
                                                     </xsl:variable>
                                                     <xsl:attribute name="time" select="$iso-time"/>
                                                 </xsl:if>
                                             </end>
                                         </range>
                                     </xsl:when>
                                     <xsl:when test="srctime/timeinfo/sngdate">
                                         <single>
                                             <xsl:variable name="iso-date">
                                                 <xsl:call-template name="to-iso-date">
                                                     <xsl:with-param name="datestr" select="fn:normalize-space(srctime/timeinfo/sngdate/caldate)"></xsl:with-param>
                                                 </xsl:call-template>
                                             </xsl:variable>
                                             <xsl:attribute name="date" select="$iso-date"/>
                                             <xsl:if test="srctime/timeinfo/sngdate/caltime">
                                                 <xsl:variable name="iso-time">
                                                     <xsl:call-template name="to-iso-time">
                                                         <xsl:with-param name="timestr" select="fn:normalize-space(srctime/timeinfo/sngdate/caltime)"></xsl:with-param>
                                                     </xsl:call-template>
                                                 </xsl:variable>
                                                 <xsl:attribute name="time" select="$iso-time"/>
                                             </xsl:if>
                                         </single>
                                     </xsl:when>
                                     <xsl:when test="srctime/timeinfo/mdattim">
                                         <xsl:for-each select="srctime/timeinfo/mdattim/sngdate">
                                             <single>
                                               <xsl:variable name="iso-date">
                                                   <xsl:call-template name="to-iso-date">
                                                       <xsl:with-param name="datestr" select="fn:normalize-space(caldate)"></xsl:with-param>
                                                   </xsl:call-template>
                                               </xsl:variable>
                                               <xsl:attribute name="date" select="$iso-date"/>
                                               <xsl:if test="time">
                                                   <xsl:variable name="iso-time">
                                                       <xsl:call-template name="to-iso-time">
                                                           <xsl:with-param name="timestr" select="fn:normalize-space(time)"></xsl:with-param>
                                                       </xsl:call-template>
                                                   </xsl:variable>
                                                   <xsl:attribute name="time" select="$iso-time"/>
                                               </xsl:if>
                                             </single>
                                         </xsl:for-each>
                                     </xsl:when>
                                 </xsl:choose>
                             </srcdate>
                         </xsl:if>
                         <xsl:if test="citation">
                             <xsl:copy-of select="citation"></xsl:copy-of>
                         </xsl:if>
                     </source>
                 </xsl:for-each>
             </sources>
            </xsl:if>
        </metadata>
    </xsl:template>
</xsl:stylesheet>