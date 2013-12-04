<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gmi="http://www.isotc211.org/2005/gmi" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx" 
    xmlns:gsr="http://www.isotc211.org/2005/gsr" 
    xmlns:gss="http://www.isotc211.org/2005/gss" 
    xmlns:gts="http://www.isotc211.org/2005/gts" 
    xmlns:gfc="http://www.isotc211.org/2005/gfc"
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="#all" >

    <xsl:import href="remove-namespaces.xsl"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!-- to remove all of the namespaces, including the default (from the original iso and do not add the xmlns for gmi back in) -->
    <xsl:variable name="cleaned">
        <xsl:call-template name="remove"></xsl:call-template>
    </xsl:variable>
    
    <xsl:template name="convert-to-geoform">
        <xsl:param name="presentation-form"/>
        <!-- another thing that cannot be unpacked -->
        <xsl:choose>
            <xsl:when test="$presentation-form='mapHardcopy'">
                <xsl:value-of select="'atlas'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='documentDigital'">
                <xsl:value-of select="'document'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='documentHardcopy'">
                <xsl:value-of select="'globe'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='mapDigital'">
                <xsl:value-of select="'map'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='modelDigital'">
                <xsl:value-of select="'model'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='modelHardcopy'">
                <xsl:value-of select="'physical model'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='imageDigital'">
                <xsl:value-of select="'multimedia presentation'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='profileDigital'">
                <xsl:value-of select="'profile'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='profileHardcopy'">
                <xsl:value-of select="'cross-section'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='mapDigital'">
                <xsl:value-of select="'raster digital data'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='imageDigital'">
                <xsl:value-of select="'remote-sensing image'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='tableDigital'">
                <xsl:value-of select="'tabular digital data'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='mapDigital'">
                <xsl:value-of select="'vector digital data'"/>
            </xsl:when>
            <xsl:when test="$presentation-form='documentDigital'">
                <xsl:value-of select="'database'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>    

    <xsl:template name="convert-to-contact" exclude-result-prefixes="#all">
        <xsl:param name="original"/>
        <xsl:element name="contact">
            <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
            <xsl:element name="position">
                <xsl:element name="name"><xsl:value-of select="$original/CI_ResponsibleParty/positionName/CharacterString"/></xsl:element>
            </xsl:element>
            <xsl:element name="organization">
                <xsl:element name="name"><xsl:value-of select="$original/CI_ResponsibleParty/organisationName/CharacterString"/></xsl:element>
            </xsl:element>
            <xsl:element name="address">
                <xsl:attribute name="type" select="'mailing and physical address'"></xsl:attribute>
                <xsl:for-each select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/deliveryPoint">
                    <xsl:element name="addr">
                        <xsl:value-of select="CharacterString"></xsl:value-of>
                    </xsl:element>
                </xsl:for-each>
                <xsl:element name="city">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/city/CharacterString"></xsl:value-of>
                </xsl:element>
                <xsl:element name="state">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/administrativeArea/CharacterString"></xsl:value-of>
                </xsl:element>
                <xsl:element name="postal">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/postalCode/CharacterString"></xsl:value-of>
                </xsl:element>
                <xsl:element name="country">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/country/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:element>
            <xsl:if test="$original/CI_ResponsibleParty/contactInfo/CI_Contact/phone/CI_Telephone/voice">
                <xsl:element name="voice">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/phone/CI_Telephone/voice/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$original/CI_ResponsibleParty/contactInfo/CI_Contact/phone/CI_Telephone/facsimile">
                <xsl:element name="fax">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/phone/CI_Telephone/facsimile/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/electronicMailAddress">
                <xsl:element name="email">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/electronicMailAddress/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$original/CI_ResponsibleParty/contactInfo/CI_Contact/hoursOfService">
                <xsl:element name="hours">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/hoursOfService/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$original/CI_ResponsibleParty/contactInfo/CI_Contact/contactInstructions">
                <xsl:element name="instructions">
                    <xsl:value-of select="$original/CI_ResponsibleParty/contactInfo/CI_Contact/contactInstructions/CharacterString"></xsl:value-of>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template name="convert-to-citation">
        <xsl:param name="original" select="()"/>
        <xsl:param name="onlinks" select="()"/>
        <xsl:element name="citation">
            <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
            <xsl:element name="title">
                <xsl:value-of select="$original/CI_Citation/title/CharacterString"/>
            </xsl:element>
            <xsl:element name="origin">
                <!-- get the first cited responsible party here (the second is the publisher/pub place) -->
                <xsl:value-of select="$original/CI_Citation/citedResponsibleParty[1]/CI_ResponsibleParty/organisationName/CharacterString"/>
            </xsl:element>
            <xsl:if test="$original/CI_Citation/presentationForm/CI_PresentationFormCode">
                <xsl:element name="geoform">
                    <!-- TODO: convert this back to the fgdc? -->
                    <xsl:variable name="form">
                        <xsl:call-template name="convert-to-geoform">
                            <xsl:with-param name="presentation-form" select="$original/CI_Citation/presentationForm/CI_PresentationFormCode/@codeListValue"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$form"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="publication">
                <xsl:variable name="pubdate">
                    <xsl:choose>
                        <xsl:when test="$original/CI_Citation/date/CI_Date/date/Date">
                            <xsl:value-of select="$original/CI_Citation/date/CI_Date/date/Date"/>
                        </xsl:when>
                        <xsl:when test="$original/CI_Citation/date/CI_Date/date/DateTime">
                            <xsl:value-of select="fn:substring-before($original/CI_Citation/date/CI_Date/date/DateTime, 'T')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Unknown'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="pubtime">
                    <xsl:choose>
                        <xsl:when test="$original/CI_Citation/date/CI_Date/date/DateTime">
                            <xsl:value-of select="fn:substring-after($original/CI_Citation/date/CI_Date/date/DateTime, 'T')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Unknown'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:element name="pubdate">
                    <xsl:attribute name="date" select="$pubdate"></xsl:attribute>
                    <xsl:attribute name="time" select="$pubtime"></xsl:attribute>
                </xsl:element>
                
                <xsl:if test="fn:count($original/CI_Citation/citedResponsibleParty) > 1">
                    <xsl:variable name="pub-citation" select="$original/CI_Citation/citedResponsibleParty[2]"/>
                    <xsl:if test="$pub-citation/CI_ResponsibleParty/contactInfo/CI_Contact/address">
                        <xsl:element name="place">
                            <xsl:value-of select="fn:concat($pub-citation/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/city/CharacterString, ';', $pub-citation/CI_ResponsibleParty/contactInfo/CI_Contact/address/CI_Address/administrativeArea/CharacterString)"></xsl:value-of>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="$pub-citation/CI_ResponsibleParty/organisationName">
                        <xsl:element name="publisher">
                            <xsl:value-of select="$pub-citation/CI_ResponsibleParty/organisationName/CharacterString"/>
                        </xsl:element>
                    </xsl:if>   
                </xsl:if>
            </xsl:element>
            <xsl:if test="$original/parent::node()/name() = 'MD_DataIdentification'">
                <xsl:for-each select="$onlinks/onlink">
                    <xsl:element name="onlink">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template name="convert-to-source">
        <xsl:param name="original"/>
        <xsl:param name="local-citations"/>
        <xsl:element name="source">
            <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
            <xsl:attribute name="type" select="''"></xsl:attribute>
            <xsl:variable name="src-description" select="$original/LI_Source/description/CharacterString"/>
            <xsl:if test="$src-description">
                <xsl:element name="type">See Source Contribution for more information.</xsl:element>
            </xsl:if>
            
            <xsl:if test="$original/LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString">
                <xsl:element name="alias">
                    <xsl:value-of select="$original/LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString"/>
                </xsl:element>
            </xsl:if>
            
            <xsl:if test="$src-description">
                <xsl:element name="contribution">
                    <xsl:value-of select="$src-description"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/*/description">
                <xsl:element name="current">
                    <xsl:value-of select="($original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/*/description)[1]"></xsl:value-of>
                </xsl:element>
            </xsl:if>
            
            <xsl:element name="srcdate">
                <xsl:choose>
                    <xsl:when test="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition">
                        <xsl:element name="range">
                            <!-- convert to date and time) -->
                            <xsl:variable name="begstr" select="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition"/>   
                            <xsl:variable name="begdate">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($begstr, 'T')">
                                        <xsl:value-of select="fn:substring-before($begstr, 'T')"/>
                                    </xsl:when>
                                    <xsl:when test="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition/@indeterminatePosition">
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$begstr"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="begtime">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($begstr, 'T')">
                                        <xsl:value-of select="fn:substring-after($begstr, 'T')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <xsl:element name="start">
                                <xsl:attribute name="date" select="$begdate"></xsl:attribute>
                                <xsl:attribute name="time" select="$begtime"></xsl:attribute>
                            </xsl:element>
                            
                            <xsl:variable name="endstr" select="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/endPosition"/>
                            <xsl:variable name="enddate">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($endstr, 'T')">
                                        <xsl:value-of select="fn:substring-before($endstr, 'T')"/>
                                    </xsl:when>
                                    <xsl:when test="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/endPosition/@indeterminatePosition">
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$endstr"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="endtime">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($endstr, 'T')">
                                        <xsl:value-of select="fn:substring-after($endstr, 'T')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:element name="end">
                                <xsl:attribute name="date" select="$enddate"></xsl:attribute>
                                <xsl:attribute name="time" select="$endtime"></xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="fn:count($original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimeInstant/timePosition) = 1">
                        <xsl:variable name="datestr" select="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimeInstant/timePosition"/>
                        <xsl:variable name="date">
                            <xsl:choose>
                                <xsl:when test="fn:contains($datestr, 'T')">
                                    <xsl:value-of select="fn:substring-before($datestr, 'T')"/>
                                </xsl:when>
                                <xsl:when test="$datestr and not(fn:contains($datestr, 'T'))">
                                    <xsl:value-of select="$datestr"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Unknown'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="time">
                            <xsl:choose>
                                <xsl:when test="fn:contains($datestr, 'T')">
                                    <xsl:value-of select="fn:substring-after($datestr, 'T')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Unknown'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:element name="single">
                            <xsl:attribute name="date" select="$date"></xsl:attribute>
                            <xsl:attribute name="time" select="$time"></xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="fn:count($original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimeInstant/timePosition) > 1">
                        <xsl:for-each select="$original/LI_Source/sourceExtent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimeInstant/timePosition">
                            <xsl:variable name="datestr" select="."/>
                            <xsl:variable name="date">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($datestr, 'T')">
                                        <xsl:value-of select="fn:substring-before($datestr, 'T')"/>
                                    </xsl:when>
                                    <xsl:when test="$datestr and not(fn:contains($datestr, 'T'))">
                                        <xsl:value-of select="$datestr"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="time">
                                <xsl:choose>
                                    <xsl:when test="fn:contains($datestr, 'T')">
                                        <xsl:value-of select="fn:substring-after($datestr, 'T')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:element name="single">
                                <xsl:attribute name="date" select="$date"></xsl:attribute>
                                <xsl:attribute name="time" select="$time"></xsl:attribute>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <!-- TODO: add the citation data -->
            <xsl:variable name="src-citation">
                <xsl:call-template name="convert-to-citation">
                    <xsl:with-param name="original" select="$original/LI_Source/sourceCitation"></xsl:with-param>
                    <xsl:with-param name="onlinks" select="()"></xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="src-citation-id" select="$local-citations/citation[. = $src-citation/citation]/@id" ></xsl:variable>
            <xsl:element name="citation">
                <xsl:attribute name="ref" select="$src-citation-id"></xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="/">
        <xsl:variable name="dataset-uuid" select="$cleaned/MI_Metadata/dataSetURI/CharacterString"/>
        <xsl:variable name="file-path" select="fn:replace(fn:replace(fn:base-uri(/), '.xml', ''), $dataset-uuid, '')"></xsl:variable>
       
        <xsl:variable name="all-onlinks">
            <xsl:if test="$cleaned/MI_Metadata/distributionInfo/MD_Distribution/transferOptions">
                <xsl:for-each select="$cleaned/MI_Metadata/distributionInfo/MD_Distribution/transferOptions/MD_DigitalTransferOptions/onLine">
                    <xsl:element name="onlink">
                        <xsl:value-of select="CI_OnlineResource/linkage/URL"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        
        <!-- NOTE: not going to be unique - the role codes screw that up -->
        <xsl:variable name="all-contacts">
            <xsl:element name="contacts">
                <xsl:for-each-group select="$cleaned/MI_Metadata/contact | $cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/pointOfContact | $cleaned/MI_Metadata/metadataMaintenance/MD_MaintenanceInformation/contact | $cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/lineage/LI_Lineage/processStep/LI_ProcessStep/processor" group-by=".">
                    <xsl:call-template name="convert-to-contact">
                        <xsl:with-param name="original" select="."></xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each-group>
            </xsl:element>
        </xsl:variable>   
       
       <!-- and now use the repacked contacts to id just the unique contacts. use this list as the refs -->
        <xsl:variable name="unique-contacts">
            <xsl:for-each-group select="$all-contacts/contacts/contact" group-by=".">
                <xsl:element name="contact">
                    <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
                    <xsl:copy-of select="node()"></xsl:copy-of>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:variable name="all-citations">
            <xsl:element name="citations">
                <xsl:for-each-group select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/citation | $cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/lineage/LI_Lineage/source/LI_Source/sourceCitation" group-by=".">
                    <xsl:call-template name="convert-to-citation">
                        <xsl:with-param name="original" select="."/>
                        <xsl:with-param name="onlinks" select="$all-onlinks"></xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each-group>
            </xsl:element>
        </xsl:variable>
        
        <xsl:variable name="unique-citations">
            <xsl:for-each-group select="$all-citations/citations/citation" group-by=".">
                <xsl:element name="citation">
                    <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
                    <xsl:copy-of select="node()" copy-namespaces="no"></xsl:copy-of>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:variable name="all-sources">            
            <xsl:element name="sources">
                <xsl:for-each-group select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/lineage/LI_Lineage/source" group-by=".">
                    <xsl:call-template name="convert-to-source">
                        <xsl:with-param name="original" select="."/>
                        <xsl:with-param name="local-citations" select="$unique-citations"/>
                    </xsl:call-template>
                </xsl:for-each-group>
            </xsl:element>
        </xsl:variable>
        
        <xsl:variable name="unique-sources">
            <xsl:for-each-group select="$all-sources/sources/source" group-by=".">
                <xsl:element name="source">
                    <xsl:attribute name="id" select="generate-id()"></xsl:attribute>
                    <xsl:copy-of select="node()" copy-namespaces="no"></xsl:copy-of>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
        
        <metadata>          
            <original>
                <standard version="{$cleaned/MI_Metadata/metadataStandardVersion/CharacterString}">
                    <title><xsl:value-of select="$cleaned/MI_Metadata/metadataStandardName/CharacterString"/></title>
                </standard>
            </original>
            <identification>
                <xsl:if test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation">
                    <xsl:attribute name="dataset" select="$dataset-uuid"/>
                </xsl:if>
                <title>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/citation/CI_Citation/title/CharacterString"></xsl:value-of>
                </title>
                <abstract>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/abstract/CharacterString"/>
                </abstract>
                <purpose>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/purpose/CharacterString"/>
                </purpose>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/supplementalInformation/CharacterString">
                    <supplinfo>
                        <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/supplementalInformation/CharacterString"/>
                    </supplinfo>
                </xsl:if>

                <xsl:variable name="point-contact">
                    <xsl:call-template name="convert-to-contact">
                        <xsl:with-param name="original" select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/pointOfContact"></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="point-contact-id" select="$unique-contacts/contact[.=$point-contact/contact]/@id"/>
                <contact role="point-contact" ref="{$point-contact-id}"></contact>
                
                <!-- TODO: add the larger work citation ref -->
                <xsl:variable name="id-citation">
                    <xsl:call-template name="convert-to-citation">
                        <xsl:with-param name="original" select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/citation"/>
                        <xsl:with-param name="onlinks" select="$all-onlinks"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="id-citation-id" select="$unique-citations/citation[.=$id-citation/citation]/@id"/>
                <citation role="identify" ref="{$id-citation-id}"></citation>
                
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement">
                    <time>
                         <xsl:choose>
                             <!-- TODO: add better date reformatting FOR ALL DATES -->
                             <xsl:when test="fn:count($cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement) > 1">
                                 <!-- it's a multiple datetime -->
                                 <xsl:for-each select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement">
                                     <xsl:variable name="datestr" select="EX_TemporalExtent/extent/TimeInstant/timePosition"/>
                                     <xsl:variable name="date">
                                         <xsl:choose>
                                             <xsl:when test="fn:contains($datestr, 'T')">
                                                 <xsl:value-of select="fn:substring-before($datestr, 'T')"/>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                 <xsl:value-of select="$datestr"/>
                                             </xsl:otherwise>
                                         </xsl:choose>
                                     </xsl:variable>
                                     <xsl:variable name="time">
                                         <xsl:choose>
                                             <xsl:when test="fn:contains($datestr, 'T')">
                                                 <xsl:value-of select="fn:substring-after($datestr, 'T')"/>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                 <xsl:value-of select="'Unknown'"/>
                                             </xsl:otherwise>
                                         </xsl:choose>
                                     </xsl:variable>
                                     <single date="{$date}" time="{$time}"/>
                                 </xsl:for-each>
                             </xsl:when>
                             <xsl:when test="fn:count($cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement) = 1 and not($cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition)">
                                 <!-- it's a single datetime -->
                                 <xsl:variable name="datestr" select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimeInstant/timePosition"/>
                                 <xsl:variable name="date">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($datestr, 'T')">
                                             <xsl:value-of select="fn:substring-before($datestr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="$datestr"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <xsl:variable name="time">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($datestr, 'T')">
                                             <xsl:value-of select="fn:substring-after($datestr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="'Unknown'"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <single date="{$date}" time="{$time}"/>
                             </xsl:when>
                             <xsl:when test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition">
                                 <!-- it's a time range -->
                                 <xsl:variable name="begstr" select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition"/>
                                 <xsl:variable name="endstr" select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/endPosition"/>
                                 
                                 <!-- check for a date vs. datetime -->
                                 <xsl:variable name="begdate">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($begstr, 'T')">
                                             <xsl:value-of select="fn:substring-before($begstr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="$begstr"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <xsl:variable name="begtime">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($begstr, 'T')">
                                             <xsl:value-of select="fn:substring-after($begstr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="'Unknown'"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <xsl:variable name="enddate">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($endstr, 'T')">
                                             <xsl:value-of select="fn:substring-before($endstr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="$endstr"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <xsl:variable name="endtime">
                                     <xsl:choose>
                                         <xsl:when test="fn:contains($endstr, 'T')">
                                             <xsl:value-of select="fn:substring-after($endstr, 'T')"/>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:value-of select="'Unknown'"/>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:variable>
                                 <range>
                                     <start date="{$begdate}" time="{$begtime}"/>
                                     <end date="{$enddate}" time="{$endtime}"/>
                                 </range>
                             </xsl:when>
                         </xsl:choose>
                        <current>
                            <!-- search for the description in any of the possible time structures -->
                            <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement[1]//description"></xsl:value-of>
                        </current>
                    </time>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/topicCategory">
                    <isotopic>
                        <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/topicCategory/MD_TopicCategoryCode"></xsl:value-of>
                    </isotopic>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='theme']">
                   <themes>
                       <xsl:for-each select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='theme']">
                           <theme thesaurus="{MD_Keywords/thesaurusName/CI_Citation/title/CharacterString}">
                               <xsl:for-each select="MD_Keywords/keyword">
                                   <term><xsl:value-of select="CharacterString"></xsl:value-of></term>
                               </xsl:for-each>
                           </theme>
                       </xsl:for-each>
                   </themes>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='place']">
                    <places>
                        <xsl:for-each select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='place']">
                            <place thesaurus="{MD_Keywords/thesaurusName/CI_Citation/title/CharacterString}">
                                <xsl:for-each select="MD_Keywords/keyword">
                                    <term><xsl:value-of select="CharacterString"></xsl:value-of></term>
                                </xsl:for-each>
                            </place>
                        </xsl:for-each>
                    </places>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='temporal']">
                     <temporals>
                         <xsl:for-each select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='temporal']">
                             <temporal thesaurus="{MD_Keywords/thesaurusName/CI_Citation/title/CharacterString}">
                                 <xsl:for-each select="MD_Keywords/keyword">
                                     <term><xsl:value-of select="CharacterString"></xsl:value-of></term>
                                 </xsl:for-each>
                             </temporal>
                         </xsl:for-each>
                     </temporals>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='stratum']">
                    <stratums>
                        <xsl:for-each select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords[MD_Keywords/type/MD_KeywordTypeCode/@codeListValue='stratum']">
                            <stratum thesaurus="{MD_Keywords/thesaurusName/CI_Citation/title/CharacterString}">
                                <xsl:for-each select="MD_Keywords/keyword">
                                    <term><xsl:value-of select="CharacterString"></xsl:value-of></term>
                                </xsl:for-each>
                            </stratum>
                        </xsl:for-each>
                    </stratums>
                </xsl:if>
            
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/environmentDescription">
                    <native>
                        <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/environmentDescription/CharacterString"></xsl:value-of>
                    </native>
                </xsl:if>
                
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/credit">
                    <credit>
                        <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/credit/CharacterString"/>
                    </credit>
                </xsl:if>
            
            </identification>
            <constraints>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints">
                    <!-- stupid iso -->
                    <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints/accessConstraints">
                        <access type="data" code="{$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints/accessConstraints/MD_RestrictionCode/@codeListValue}">See Other data constraints for more information.</access>
                    </xsl:if>
                    <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints/useConstraints">
                        <use type="data" code="{$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints/useConstraints/MD_RestrictionCode/@codeListValue}">See Other data constraints for more information.</use>
                    </xsl:if>
                    <other type="data">
                        <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_LegalConstraints/otherConstraints/CharacterString"/>
                    </other>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_SecurityConstraints">
                    <security type="data">
                        <classification system="Unknown">
                            <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_SecurityConstraints/classificationSystem/CharacterString"></xsl:value-of>
                        </classification>
                        <handling>
                            <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceConstraints/MD_SecurityConstraints/handlingDescription/CharacterString"></xsl:value-of>
                        </handling>
                    </security>
                </xsl:if>
                
                <xsl:if test="$cleaned/MI_Metadata/metadataConstraints/MD_LegalConstraints">
                    <xsl:if test="MI_Metadata/metadataConstraints/MD_LegalConstraints/accessConstraints">
                        <access type="metadata" code="MI_Metadata/metadataConstraints/MD_LegalConstraints/accessConstraints/MD_RestrictionCode/@codeListValue">See Other metadata constraints for more information.</access>
                    </xsl:if>
                    <xsl:if test="MI_Metadata/metadataConstraints/MD_LegalConstraints/useConstraints">
                        <use type="metadata" code="MI_Metadata/metadataConstraints/MD_LegalConstraints/useConstraints/MD_RestrictionCode/@codeListValue">See Other metadata constraints for more information.</use>
                    </xsl:if>
                    <other type="metadata">
                        <xsl:value-of select="MI_Metadata/metadataConstraints/MD_LegalConstraints/otherConstraints/CharacterString"/>
                    </other>
                </xsl:if>
                <xsl:if test="MI_Metadata/metadataConstraints/MD_SecurityConstraints">
                    <security type="metadata">
                        <classification system="{$cleaned/MI_Metadata/metadataConstraints/MD_SecurityConstraints/classificationSystem/CharacterString}">
                            <xsl:value-of select="$cleaned/MI_Metadata/metadataConstraints/MD_SecurityConstraints/classification/MD_ClassificationCode/@codeListValue"/>
                        </classification>
                        <xsl:choose>
                            <xsl:when test="$cleaned/MI_Metadata/metadataConstraints/MD_SecurityConstraints/handlingDescription">
                                <handling>
                                    <xsl:value-of select="$cleaned/MI_Metadata/metadataConstraints/MD_SecurityConstraints/handlingDescription/CharacterString"/>
                                </handling>
                            </xsl:when>
                            <xsl:otherwise>
                                <handling>Unknown</handling>
                            </xsl:otherwise>
                        </xsl:choose>
                    </security>
                </xsl:if>
            </constraints>
            <spatial>
                <west>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/westBoundLongitude/Decimal"></xsl:value-of>
                </west>
                <east>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/eastBoundLongitude/Decimal"></xsl:value-of>
                </east>
                <south>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/southBoundLatitude/Decimal"></xsl:value-of>
                </south>
                <north>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/northBoundLatitude/Decimal"></xsl:value-of>
                </north>
                <!-- TODO: add check to be code WITHOUT sibling of authority (currently very ugly checks) -->
                <xsl:if test="$cleaned/MI_Metadata/referenceSystemInfo/MD_ReferenceSystem/referenceSystemIdentifier/RS_Identifier/code[not(following-sibling::authority) and not(preceding-sibling::authority)]">
                    <indspref>
                        <xsl:value-of select="fn:normalize-space($cleaned/MI_Metadata/referenceSystemInfo/MD_ReferenceSystem/referenceSystemIdentifier/RS_Identifier/code[not(following-sibling::authority) and not(preceding-sibling::authority)]/CharacterString)"></xsl:value-of>
                    </indspref>
                </xsl:if>
                
                <sprefs>
                    <xsl:for-each select="$cleaned/MI_Metadata/referenceSystemInfo/MD_ReferenceSystem/referenceSystemIdentifier/RS_Identifier[authority and code]">
                        <spref type="Unknown">
                            <code>
                                <!-- TODO: update this for times when there's no separator -->
                                <xsl:value-of select="fn:substring-after(code/CharacterString, '::')"/>
                            </code>
                            <authority>
                                <xsl:value-of>
                                    <xsl:choose>
                                        <xsl:when test="fn:contains(code/CharacterString, 'EPSG')">
                                            <xsl:value-of select="'EPSG'"/>
                                        </xsl:when>
                                        <xsl:when test="fn:contains(code/CharacterString, 'ESRI')">
                                            <xsl:value-of select="'ESRI'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'Unknown'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:value-of>
                            </authority>
                            <onlineref>
                                <xsl:value-of select="authority/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/contactInfo/CI_Contact/onlineResource/CI_OnlineResource/linkage/URL"></xsl:value-of>
                            </onlineref>
                            <title>
                                <xsl:value-of select="authority/CI_Citation/title/CharacterString"></xsl:value-of>
                            </title>
                        </spref>
                    </xsl:for-each>
                </sprefs>
                
                <!-- TODO: needs a better check for raster v vector v file -->
                <xsl:choose>
                    <xsl:when test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation">
                        <raster cval="Unknown">
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation/cellGeometry/MD_CellGeometryCode[@codeListValue='point']">
                                        <xsl:value-of select="'Pixel'"></xsl:value-of>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <rows>
                                <xsl:value-of select="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation/axisDimensionProperties/MD_Dimension[dimensionName/MD_DimensionNameTypeCode/@codeListValue='row']/dimensionSize/Integer"></xsl:value-of>
                            </rows>
                            <columns>
                                <xsl:value-of select="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation/axisDimensionProperties/MD_Dimension[dimensionName/MD_DimensionNameTypeCode/@codeListValue='column']/dimensionSize/Integer"></xsl:value-of>
                            </columns>
                            <xsl:if test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation/axisDimensionProperties/MD_Dimension[dimensionName/MD_DimensionNameTypeCode/@codeListValue='vertical']">
                                <verticals>
                                    <xsl:value-of select="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation/axisDimensionProperties/MD_Dimension[dimensionName/MD_DimensionNameTypeCode/@codeListValue='vertical']/dimensionSize/Integer"></xsl:value-of>
                                </verticals>
                            </xsl:if>
                        </raster>
                    </xsl:when>
                    <xsl:when test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_VectorSpatialRepresentation">
                        <vector>
                            <xsl:for-each select="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_VectorSpatialRepresentation/geometricObjects">
                                <xsl:variable name="vector-type">
                                    <xsl:choose>
                                        <!-- can't ever go back. -->
                                        <xsl:when test="MD_GeometricObjects/geometricObjectType/MD_GeometricObjectTypeCode[@codeListValue = 'point']">
                                            <xsl:value-of select="'Point'"/>
                                        </xsl:when>
                                        <xsl:when test="MD_GeometricObjects/geometricObjectType/MD_GeometricObjectTypeCode[@codeListValue = 'surface']">
                                            <xsl:value-of select="'Node, planar graph'"/>
                                        </xsl:when>
                                        <xsl:when test="MD_GeometricObjects/geometricObjectType/MD_GeometricObjectTypeCode[@codeListValue = 'curve']">
                                            <xsl:value-of select="'Complete chain'"/>
                                        </xsl:when>
                                        <xsl:when test="MD_GeometricObjects/geometricObjectType/MD_GeometricObjectTypeCode[@codeListValue = 'composite']">
                                            <xsl:value-of select="'Ring with mixed composition'"/>
                                        </xsl:when>
                                        <xsl:when test="MD_GeometricObjects/geometricObjectType/MD_GeometricObjectTypeCode[@codeListValue = 'complex']">
                                            <xsl:value-of select="'G-polygon'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'Unknown'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <sdts type="{$vector-type}" features="{MD_GeometricObjects/geometricObjectCount/Integer}"></sdts>
                            </xsl:for-each>
                        </vector>
                    </xsl:when>
                </xsl:choose>
            </spatial>
            <quality>
                <progress>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/status/MD_ProgressCode/@codeListValue"></xsl:value-of>
                </progress>
                <update>
                    <xsl:value-of select="$cleaned/MI_Metadata/identificationInfo/MD_DataIdentification/resourceMaintenance/MD_MaintenanceInformation/maintenanceAndUpdateFrequency/MD_MaintenanceFrequencyCode/@codeListValue"></xsl:value-of>
                </update>
                <logical>
                    <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_ConceptualConsistency/measureDescription/CharacterString"></xsl:value-of>
                </logical>
                <completeness>
                    <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_CompletenessOmission/evaluationMethodDescription/CharacterString"></xsl:value-of>
                </completeness>
                
                <xsl:if test="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_QuantitativeAttributeAccuracy[nameOfMeasure/CharacterString='Quantitative Attribute Accuracy Assessment']">
                    <qual type="attribute">
                        <report>
                            <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_QuantitativeAttributeAccuracy[nameOfMeasure/CharacterString='Quantitative Attribute Accuracy Assessment']/measureDescription/CharacterString"></xsl:value-of>
                        </report>
                        
                        <quantitative>
                            <value>
                                <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_QuantitativeAttributeAccuracy[nameOfMeasure/CharacterString='Quantitative Attribute Accuracy Assessment']/result/DQ_QuantitativeResult/value/Record"></xsl:value-of>
                            </value>
                            <explanation>
                                <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_QuantitativeAttributeAccuracy[nameOfMeasure/CharacterString='Quantitative Attribute Accuracy Assessment']/evaluationMethodDescription/CharacterString"></xsl:value-of>
                            </explanation>
                        </quantitative>
                    </qual>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Horizontal Positional Accuracy']">
                    <qual type="horizontal">
                        <report>
                            <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Horizontal Positional Accuracy']/evaluationMethodDescription/CharacterString"></xsl:value-of>
                        </report>
                        
                        <!-- for more than one result (although to me the evaluationMethod and the measureDescription are reversed from the csdgm transform, but I'm not sure what's up with that -->
                        <xsl:for-each select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report[DQ_AbsoluteExternalPositionalAccuracy/nameOfMeasure/CharacterString='Horizontal Positional Accuracy']">
                            <quantitative>
                                <value>
                                    <xsl:value-of select="DQ_AbsoluteExternalPositionalAccuracy/result/DQ_QuantitativeResult/value/Record"></xsl:value-of>
                                </value>
                                <explanation>
                                    <xsl:value-of select="DQ_AbsoluteExternalPositionalAccuracy/measureDescription/CharacterString"></xsl:value-of>
                                </explanation>
                            </quantitative>
                        </xsl:for-each>
                    </qual>
                </xsl:if>
                <xsl:if test="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Vertical Positional Accuracy']">
                    <qual type="vertical">
                        <report>
                            <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Vertical Positional Accuracy']/measureDescription/CharacterString"></xsl:value-of>
                        </report>
                        <quantitative>
                            <value>
                                <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Vertical Positional Accuracy']/result/DQ_QuantitativeResult/value/Record"></xsl:value-of>
                            </value>
                            <explanation>
                                <xsl:value-of select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/report/DQ_AbsoluteExternalPositionalAccuracy[nameOfMeasure/CharacterString='Vertical Positional Accuracy']/evaluationMethodDescription/CharacterString"></xsl:value-of>
                            </explanation>
                        </quantitative>
                    </qual>
                </xsl:if>
            
                <xsl:if test="$cleaned/MI_Metadata/contentInfo/MD_ImageDescription/cloudCoverPercentage[not(@nilReason)]">
                    <cloud ref="Unknown">
                        <xsl:value-of select="$cleaned/MI_Metadata/contentInfo/MD_ImageDescription/cloudCoverPercentage/Real"></xsl:value-of>
                    </cloud>
                </xsl:if>
            </quality>
            <lineage>
                <xsl:for-each select="$cleaned/MI_Metadata/dataQualityInfo/DQ_DataQuality/lineage/LI_Lineage/processStep">
                    <step id="{position()}">
                        <description>
                            <xsl:value-of select="LI_ProcessStep/description/CharacterString"></xsl:value-of>
                        </description>
                        <rundate>
                            <!-- iso procdate must be datetime! -->
                            <xsl:attribute name="date">
                                <xsl:choose>
                                    <xsl:when test="LI_ProcessStep/dateTime/DateTime">
                                        <xsl:value-of select="fn:substring-before(LI_ProcessStep/dateTime/DateTime, 'T')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="time">
                                <xsl:choose>
                                    <xsl:when test="LI_ProcessStep/dateTime/DateTime">
                                        <xsl:value-of select="fn:substring-after(LI_ProcessStep/dateTime/DateTime, 'T')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </rundate>
                        <xsl:if test="LI_ProcessStep/processor">
                            <xsl:variable name="step-contact">
                                <xsl:call-template name="convert-to-contact">
                                    <xsl:with-param name="original" select="LI_ProcessStep/processor"></xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="step-contact-id" select="$unique-contacts/contact[.=$step-contact/contact]/@id"/>
                            <contact role="responsible-party" ref="{$step-contact-id}"></contact>
                        </xsl:if>
                        
                        <xsl:if test="LI_ProcessStep/source/LI_Source/sourceCitation/CI_Citation/title">
                            <xsl:variable name="proc-source" select="LI_ProcessStep/source"></xsl:variable>
                            <xsl:variable name="proc-source-id" select="$all-sources/sources/source[LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString = $proc-source/LI_Source/sourceCitation/CI_Citation/title/CharacterString]/@id"></xsl:variable>
                            <source ref="{$proc-source-id}" type="used"/>
                            
                            <!-- <source ref="" type="prod"></source>  -->
                        </xsl:if>
                        
                        
                    </step>
                </xsl:for-each>
            </lineage>

            <xsl:if test="$cleaned/MI_Metadata/spatialRepresentationInfo/MD_VectorSpatialRepresentation">
                <attributes>
                    <xsl:variable name="eainfo-orig" select="document(fn:concat($file-path, 'FC_', $dataset-uuid, '.xml'))"></xsl:variable>
                    <!-- strip out the namespaces -->
                    <xsl:variable name="eainfo-data">
                        <xsl:apply-templates select="$eainfo-orig" mode="remove"></xsl:apply-templates>
                    </xsl:variable>
                   
                    <!-- TODO: add entity, overview, etc (how can we id overview - it is junk in iso) -->
                    <entity>
                        <label><xsl:value-of select="$eainfo-data/FC_FeatureCatalogue/featureType/FC_FeatureType/typeName/LocalName"></xsl:value-of></label>
                        <description>
                            <xsl:value-of select="$eainfo-data/FC_FeatureCatalogue/featureType/FC_FeatureType/definition/CharacterString"></xsl:value-of>
                        </description>
                        <xsl:if test="$eainfo-data/FC_FeatureCatalogue/definitionSource/FC_DefinitionSource/source/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/organisationName/CharacterString">
                            <source>
                                <xsl:value-of select="$eainfo-data/FC_FeatureCatalogue/definitionSource/FC_DefinitionSource/source/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/organisationName/CharacterString"/>
                            </source>
                        </xsl:if>
                    </entity>
                
                    <xsl:for-each select="$eainfo-data/FC_FeatureCatalogue/featureType/FC_FeatureType/carrierOfCharacteristics">
                        <attr>
                            <label>
                                <xsl:value-of select="FC_FeatureAttribute/memberName/LocalName"></xsl:value-of>
                            </label>
                            <definition>
                                <xsl:value-of select="FC_FeatureAttribute/definition/CharacterString"></xsl:value-of>
                            </definition>
                            <source>
                                <xsl:value-of select="FC_FeatureAttribute/definitionReference/FC_DefinitionReference/definitionSource/FC_DefinitionSource/source/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/organisationName/CharacterString"></xsl:value-of>
                            </source>
                            
                            <xsl:variable name="attr-type">
                                <xsl:choose>
                                    <xsl:when test="FC_FeatureAttribute/valueType/TypeName/aName">
                                        <xsl:value-of select="'unrepresented'"></xsl:value-of>
                                    </xsl:when>
                                    <xsl:when test="FC_FeatureAttribute/listedValue and FC_FeatureAttribute/listedValue/FC_ListedValue/definition">
                                        <xsl:value-of select="'enumerated'"></xsl:value-of>
                                    </xsl:when>
                                    <xsl:when test="FC_FeatureAttribute/listedValue and not(FC_FeatureAttribute/listedValue/FC_ListedValue/definition)">
                                        <xsl:value-of select="'codeset'"></xsl:value-of>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'range'"></xsl:value-of>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <xsl:choose>
                                <xsl:when test="$attr-type='unrepresented'">
                                    <unrepresented>
                                        <description><xsl:value-of select="FC_FeatureAttribute/valueType/TypeName/aName/CharacterString"></xsl:value-of></description>
                                    </unrepresented>
                                </xsl:when>
                                <!-- TODO: how to tell difference between enumerated and codeset definitions? 
                                    a) no definition for codeset?
                                -->
                                <xsl:when test="$attr-type='enumerated'">
                                    <enumerated>
                                     <xsl:for-each select="FC_FeatureAttribute/listedValue">
                                         <value>
                                             <enum>
                                                 <xsl:value-of select="FC_ListedValue/label/CharacterString"></xsl:value-of>
                                             </enum>
                                             <description>
                                                 <xsl:value-of select="FC_ListedValue/definition/CharacterString"></xsl:value-of>
                                             </description>
                                             <source>
                                                 <xsl:value-of select="FC_ListedValue/definitionReference/FC_DefinitionReference/definitionSource/FC_DefinitionSource/source/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/organisationName/CharacterString"></xsl:value-of>
                                             </source>
                                         </value>
                                     </xsl:for-each>
                                    </enumerated>
                                </xsl:when>
                                <xsl:when test="$attr-type='range'">
                                    <range>
                                        <!-- this is handled in a less than ideal way in the fc - concatenated max and min in the constraints 
                                            SO we are not going to handle it at all here and wait until the db contains this info to splice in
                                        -->
                                        <max>Unknown</max>
                                        <min>Unknown</min>
                                        <units>
                                            <xsl:value-of select="FC_FeatureAttribute/valueMeasurementUnit/BaseUnit/identifier/@codeSpace"></xsl:value-of>
                                        </units>
                                    </range>
                                </xsl:when>
                                <xsl:when test="$attr-type='codeset'">
                                    <codeset>
                                        <name>
                                            <xsl:value-of select="FC_FeatureAttribute/listedValue/FC_ListedValue/label/CharacterString"></xsl:value-of>
                                        </name>
                                        <source>
                                            <xsl:value-of select="FC_FeatureAttribute/definitionReference/FC_DefinitionReference/definitionSource/FC_DefinitionSource/source/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/organisationName/CharacterString"></xsl:value-of>
                                        </source>
                                    </codeset>
                                </xsl:when>
                            </xsl:choose>
                        </attr>
                    </xsl:for-each>
                    
                </attributes>
            </xsl:if>
            
            <xsl:if test="$cleaned/MI_Metadata/contentInfo/MD_CoverageDescription">
                <attributes>
                    <attr>
                        <label>
                            <xsl:value-of select="fn:substring-before($cleaned/MI_Metadata/contentInfo/MD_CoverageDescription/dimension/MD_Band/descriptor/CharacterString, '(')"/>
                        </label>
                        <definition>
                            <xsl:value-of select="fn:substring-before(fn:substring-after($cleaned/MI_Metadata/contentInfo/MD_CoverageDescription/dimension/MD_Band/descriptor/CharacterString, '('), ')')"/>
                        </definition>
                        <!-- TODO: maybe not this. hate iso. -->
                        <source>Unknown</source>
                        <range>
                            <min>Unknown</min>
                            <max>Unknown</max>
                            <units><xsl:value-of select="$cleaned/MI_Metadata/contentInfo/MD_CoverageDescription/dimension/MD_Band/units/UnitDefinition/name"/></units>
                        </range>
                    </attr>
                </attributes>
            </xsl:if>
            <metadata>               
                <xsl:variable name="meta-contact">
                    <xsl:call-template name="convert-to-contact">
                        <xsl:with-param name="original" select="$cleaned/MI_Metadata/metadataMaintenance/MD_MaintenanceInformation/contact"></xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="meta-contact-id" select="$unique-contacts/contact[.=$meta-contact/contact]/@id"/>
                <contact role="point-contact" ref="{$meta-contact-id}"></contact>
                
                <!-- the main dateStamp -->
                <xsl:variable name="md-datestr" select="$cleaned/MI_Metadata/dateStamp/Date"/>
                <pubdate date="{$md-datestr}"/>
            </metadata>
            
            <!-- dump all of the constants -->
            <xsl:if test="fn:count($unique-contacts/contact) > 0">
                <contacts>
                    <xsl:for-each select="$unique-contacts/contact">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </xsl:for-each>
                </contacts>
            </xsl:if>
            <xsl:if test="fn:count($unique-citations/citation) > 0">
                <citations>
                    <xsl:for-each select="$unique-citations/citation">
                        <xsl:copy-of select="." copy-namespaces="no"></xsl:copy-of>
                    </xsl:for-each>
                </citations>
            </xsl:if>
            <xsl:if test="$unique-sources/source">
                <sources>
                    <xsl:for-each select="$unique-sources/source">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </xsl:for-each>
                </sources>
            </xsl:if>
            
        </metadata>
    </xsl:template>
</xsl:stylesheet>